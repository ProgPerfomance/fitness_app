library analytics_package;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _queueStorageKey = 'analytics_package.queue.v1';
const String _userIdStorageKey = 'analytics_package.user_id.v1';

class AnalyticsSdkConfig {
  const AnalyticsSdkConfig({
    required this.projectId,
    this.baseUrl = 'http://localhost:8080',
    this.requestTimeout = const Duration(seconds: 10),
    this.initialRetryDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(minutes: 1),
    this.jitterRatio = 0.2,
    this.enabledByDefault = true,
  });

  final String projectId;
  final String baseUrl;
  final Duration requestTimeout;
  final Duration initialRetryDelay;
  final Duration maxRetryDelay;
  final double jitterRatio;
  final bool enabledByDefault;
}

class Analytics {
  Analytics._();

  static final AnalyticsSdk _sdk = AnalyticsSdk();

  static Future<void> init(AnalyticsSdkConfig config) => _sdk.init(config);

  static Future<void> setUserId(String userId) => _sdk.setUserId(userId);

  static String? get userId => _sdk.userId;

  static String? get platform => _sdk.platform;

  static Future<void> trackOpenApp() => _sdk.trackOpenApp();

  static Future<void> trackEvent(String eventName) =>
      _sdk.trackEvent(eventName);

  static Future<void> trackNumber(String eventName, num value) =>
      _sdk.trackNumber(eventName, value);

  static Future<void> flush() => _sdk.flush();

  static void setEnabled(bool enabled) => _sdk.setEnabled(enabled);

  static Future<void> shutdown() => _sdk.shutdown();
}

class AnalyticsSdk {
  AnalyticsSdk._({
    http.Client? httpClient,
    SharedPreferences? sharedPreferences,
    Random? random,
  }) : _client = httpClient ?? http.Client(),
       _providedSharedPreferences = sharedPreferences,
       _random = random ?? Random(),
       _ownsClient = httpClient == null;

  static final AnalyticsSdk _singleton = AnalyticsSdk._();

  factory AnalyticsSdk() => _singleton;

  @visibleForTesting
  factory AnalyticsSdk.test({
    http.Client? httpClient,
    SharedPreferences? sharedPreferences,
    Random? random,
  }) {
    return AnalyticsSdk._(
      httpClient: httpClient,
      sharedPreferences: sharedPreferences,
      random: random,
    );
  }

  final http.Client _client;
  final SharedPreferences? _providedSharedPreferences;
  final Random _random;
  final bool _ownsClient;

  AnalyticsSdkConfig? _config;
  SharedPreferences? _prefs;
  String? _userId;
  String? _platform;
  final List<_QueuedEvent> _queue = <_QueuedEvent>[];

  Timer? _retryTimer;
  bool _enabled = true;
  bool _initialized = false;
  bool _isFlushing = false;
  bool _isShutdown = false;
  Future<void>? _flushFuture;

  bool get isEnabled => _enabled;
  String? get userId => _userId;
  String? get platform => _platform;

  Future<void> init(AnalyticsSdkConfig config) async {
    if (_isShutdown) {
      throw StateError('AnalyticsSdk is shutdown and cannot be used anymore.');
    }
    if (config.projectId.trim().isEmpty) {
      throw ArgumentError.value(
        config.projectId,
        'projectId',
        'Must not be empty',
      );
    }
    if (config.jitterRatio < 0 || config.jitterRatio > 1) {
      throw ArgumentError.value(
        config.jitterRatio,
        'jitterRatio',
        'Must be in range [0, 1]',
      );
    }

    _config = config;
    _enabled = config.enabledByDefault;
    _prefs ??=
        _providedSharedPreferences ?? await SharedPreferences.getInstance();

    _platform = _detectPlatform();
    await _restoreQueue();
    await _ensureUserId();

    _initialized = true;

    if (_enabled) {
      unawaited(flush());
    }
  }

  Future<void> setUserId(String userId) async {
    _throwIfShutdown();
    _throwIfNotInitialized();
    final String normalized = userId.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Must not be empty');
    }
    _userId = normalized;
    await _prefs?.setString(_userIdStorageKey, normalized);
  }

  Future<void> trackOpenApp() {
    return _enqueue(event: 'open_app', value: null);
  }

  Future<void> trackEvent(String eventName) {
    return _enqueue(event: eventName, value: null);
  }

  Future<void> trackNumber(String eventName, num value) {
    return _enqueue(event: eventName, value: value.toDouble());
  }

  void setEnabled(bool enabled) {
    _throwIfShutdown();
    _throwIfNotInitialized();

    _enabled = enabled;
    if (!enabled) {
      _retryTimer?.cancel();
      return;
    }

    _retryTimer?.cancel();
    unawaited(flush());
  }

  Future<void> flush() async {
    _throwIfShutdown();
    _throwIfNotInitialized();
    if (!_enabled) {
      return;
    }
    if (_isFlushing) {
      await (_flushFuture ?? Future<void>.value());
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = null;
    _isFlushing = true;
    _flushFuture = _runFlushLoop();
    await _flushFuture;
  }

  Future<void> _runFlushLoop() async {
    try {
      while (_enabled && _queue.isNotEmpty) {
        final _QueuedEvent next = _queue.first;
        final _SendResult result = await _send(next);

        if (result == _SendResult.accepted || result == _SendResult.drop) {
          _queue.removeAt(0);
          await _persistQueue();
          continue;
        }

        _queue[0] = next.copyWith(attempt: next.attempt + 1);
        await _persistQueue();
        _scheduleRetry(_queue.first.attempt);
        break;
      }
    } finally {
      _isFlushing = false;
      _flushFuture = null;
    }
  }

  Future<void> shutdown() async {
    if (_isShutdown) {
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = null;
    _isShutdown = true;

    if (_ownsClient) {
      _client.close();
    }
  }

  Future<void> _enqueue({required String event, double? value}) async {
    _throwIfShutdown();
    _throwIfNotInitialized();
    _validateEventName(event);

    final String? currentUserId = _userId;
    final String? currentPlatform = _platform;
    if (currentUserId == null || currentUserId.trim().isEmpty) {
      throw StateError('User id is not initialized.');
    }
    if (currentPlatform == null || currentPlatform.trim().isEmpty) {
      throw StateError('Platform is not initialized.');
    }

    if (event == 'open_app' && value != null) {
      throw ArgumentError.value(
        value,
        'value',
        'open_app does not allow value',
      );
    }

    final _QueuedEvent queuedEvent = _QueuedEvent(
      userId: currentUserId,
      event: event,
      platform: currentPlatform,
      value: value,
      occurredAtUtcIso: DateTime.now().toUtc().toIso8601String(),
      attempt: 0,
    );

    _queue.add(queuedEvent);
    await _persistQueue();

    if (_enabled) {
      unawaited(flush());
    }
  }

  Future<void> _ensureUserId() async {
    final String? storedUserId = _prefs?.getString(_userIdStorageKey);
    if (storedUserId != null && storedUserId.trim().isNotEmpty) {
      _userId = storedUserId.trim();
      return;
    }

    final String generated = _generateAnonymousUserId();
    _userId = generated;
    await _prefs?.setString(_userIdStorageKey, generated);
  }

  String _generateAnonymousUserId() {
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final int randomBits = _random.nextInt(1 << 31);
    return 'anon_${millis}_$randomBits';
  }

  Future<void> _restoreQueue() async {
    _queue.clear();
    final String? raw = _prefs?.getString(_queueStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return;
    }

    try {
      final Object decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return;
      }

      for (final dynamic item in decoded) {
        if (item is Map<String, dynamic>) {
          _queue.add(_QueuedEvent.fromJson(item));
        } else if (item is Map) {
          _queue.add(
            _QueuedEvent.fromJson(
              item.map(
                (dynamic key, dynamic value) => MapEntry(key.toString(), value),
              ),
            ),
          );
        }
      }
    } catch (_) {
      _queue.clear();
    }
  }

  Future<void> _persistQueue() async {
    final String encoded = jsonEncode(_queue.map((e) => e.toJson()).toList());
    await _prefs?.setString(_queueStorageKey, encoded);
  }

  Future<_SendResult> _send(_QueuedEvent event) async {
    final AnalyticsSdkConfig config = _config!;
    final Uri uri = Uri.parse(
      '${config.baseUrl}/sdk/projects/${Uri.encodeComponent(config.projectId)}/events',
    );

    try {
      final http.Response response = await _client
          .post(
            uri,
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(event.apiPayload),
          )
          .timeout(config.requestTimeout);

      final int code = response.statusCode;
      if (code == 202) {
        return _SendResult.accepted;
      }
      if (code >= 500) {
        return _SendResult.retry;
      }
      if (code >= 400) {
        return _SendResult.drop;
      }
      return _SendResult.drop;
    } on TimeoutException {
      return _SendResult.retry;
    } on http.ClientException {
      return _SendResult.retry;
    } catch (_) {
      return _SendResult.retry;
    }
  }

  void _scheduleRetry(int attempt) {
    final AnalyticsSdkConfig config = _config!;
    final int multiplier = 1 << (attempt - 1).clamp(0, 30);
    final Duration baseDelay = Duration(
      milliseconds: config.initialRetryDelay.inMilliseconds * multiplier,
    );
    final Duration capped = baseDelay > config.maxRetryDelay
        ? config.maxRetryDelay
        : baseDelay;

    final double randomDelta = (_random.nextDouble() * 2) - 1;
    final double jitter = 1 + (randomDelta * config.jitterRatio);
    final int jitteredMs = (capped.inMilliseconds * jitter).round().clamp(
      0,
      config.maxRetryDelay.inMilliseconds,
    );

    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(milliseconds: jitteredMs), () {
      if (_enabled && !_isShutdown) {
        unawaited(flush());
      }
    });
  }

  String _detectPlatform() {
    if (kIsWeb) {
      return 'web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return 'web';
    }
  }

  void _validateEventName(String eventName) {
    if (eventName.trim().isEmpty) {
      throw ArgumentError.value(eventName, 'eventName', 'Must not be empty');
    }
  }

  void _throwIfNotInitialized() {
    if (!_initialized || _config == null) {
      throw StateError('init(...) must be called before using AnalyticsSdk.');
    }
  }

  void _throwIfShutdown() {
    if (_isShutdown) {
      throw StateError('AnalyticsSdk is shutdown and cannot be used anymore.');
    }
  }
}

enum _SendResult { accepted, retry, drop }

class _QueuedEvent {
  const _QueuedEvent({
    required this.userId,
    required this.event,
    required this.platform,
    required this.occurredAtUtcIso,
    required this.attempt,
    this.value,
  });

  final String userId;
  final String event;
  final String platform;
  final double? value;
  final String occurredAtUtcIso;
  final int attempt;

  Map<String, Object> get apiPayload {
    final Map<String, Object> payload = <String, Object>{
      'user_id': userId,
      'event': event,
      'platform': platform,
      'occurred_at': occurredAtUtcIso,
    };
    if (value != null) {
      payload['value'] = value!;
    }
    return payload;
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'user_id': userId,
      'event': event,
      'platform': platform,
      'value': value,
      'occurred_at': occurredAtUtcIso,
      'attempt': attempt,
    };
  }

  factory _QueuedEvent.fromJson(Map<String, dynamic> json) {
    final Object? valueRaw = json['value'];
    return _QueuedEvent(
      userId: (json['user_id'] as String?) ?? '',
      event: (json['event'] as String?) ?? '',
      platform: ((json['platform'] as String?) ?? '').toLowerCase(),
      value: valueRaw is num ? valueRaw.toDouble() : null,
      occurredAtUtcIso:
          (json['occurred_at'] as String?) ??
          DateTime.now().toUtc().toIso8601String(),
      attempt: (json['attempt'] as int?) ?? 0,
    );
  }

  _QueuedEvent copyWith({int? attempt}) {
    return _QueuedEvent(
      userId: userId,
      event: event,
      platform: platform,
      value: value,
      occurredAtUtcIso: occurredAtUtcIso,
      attempt: attempt ?? this.attempt,
    );
  }
}
