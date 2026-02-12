import 'dart:async';
import 'dart:convert';

import 'package:analytics_package/analytics_package.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'trackOpenApp sends required fields with auto platform and auto user id',
    () async {
      final List<Map<String, dynamic>> requests = <Map<String, dynamic>>[];
      final MockClient client = MockClient((http.Request req) async {
        requests.add(jsonDecode(req.body) as Map<String, dynamic>);
        return http.Response('', 202);
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final AnalyticsSdk sdk = AnalyticsSdk.test(
        httpClient: client,
        sharedPreferences: prefs,
      );
      await sdk.init(const AnalyticsSdkConfig(projectId: 'project-1'));

      await sdk.trackOpenApp();
      await sdk.flush();

      expect(requests, hasLength(1));
      expect(requests.first['event'], 'open_app');
      expect(requests.first['user_id'], isA<String>());
      expect((requests.first['user_id'] as String).isNotEmpty, isTrue);
      expect(requests.first['platform'], isA<String>());
      expect(requests.first.containsKey('value'), isFalse);
      expect(requests.first['occurred_at'], isA<String>());
    },
  );

  test('setUserId overrides generated id and persists', () async {
    final List<Map<String, dynamic>> requests = <Map<String, dynamic>>[];
    final MockClient client = MockClient((http.Request req) async {
      requests.add(jsonDecode(req.body) as Map<String, dynamic>);
      return http.Response('', 202);
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AnalyticsSdk sdk = AnalyticsSdk.test(
      httpClient: client,
      sharedPreferences: prefs,
    );
    await sdk.init(const AnalyticsSdkConfig(projectId: 'project-2'));

    await sdk.setUserId('custom_user');
    await sdk.trackEvent('test_event');
    await sdk.flush();

    expect(requests, hasLength(1));
    expect(requests.first['user_id'], 'custom_user');

    final AnalyticsSdk sdk2 = AnalyticsSdk.test(
      httpClient: client,
      sharedPreferences: prefs,
    );
    await sdk2.init(const AnalyticsSdkConfig(projectId: 'project-2'));
    expect(sdk2.userId, 'custom_user');
  });

  test('trackNumber includes value in payload', () async {
    final List<Map<String, dynamic>> requests = <Map<String, dynamic>>[];
    final MockClient client = MockClient((http.Request req) async {
      requests.add(jsonDecode(req.body) as Map<String, dynamic>);
      return http.Response('', 202);
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AnalyticsSdk sdk = AnalyticsSdk.test(
      httpClient: client,
      sharedPreferences: prefs,
    );
    await sdk.init(const AnalyticsSdkConfig(projectId: 'project-3'));

    await sdk.trackNumber('purchase_amount', 42);
    await sdk.flush();

    expect(requests, hasLength(1));
    expect(requests.first['event'], 'purchase_amount');
    expect(requests.first['value'], 42.0);
  });

  test('4xx response is not retried and event is dropped', () async {
    int calls = 0;
    final MockClient client = MockClient((http.Request req) async {
      calls += 1;
      return http.Response('{"error":"bad payload"}', 400);
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AnalyticsSdk sdk = AnalyticsSdk.test(
      httpClient: client,
      sharedPreferences: prefs,
    );
    await sdk.init(
      const AnalyticsSdkConfig(
        projectId: 'project-4',
        initialRetryDelay: Duration(milliseconds: 10),
        maxRetryDelay: Duration(milliseconds: 50),
      ),
    );

    await sdk.trackEvent('broken_event');
    await sdk.flush();
    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(calls, 1);
  });

  test('network error is retried and eventually delivered', () async {
    int calls = 0;
    final MockClient client = MockClient((http.Request req) async {
      calls += 1;
      if (calls == 1) {
        throw http.ClientException('offline');
      }
      return http.Response('', 202);
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AnalyticsSdk sdk = AnalyticsSdk.test(
      httpClient: client,
      sharedPreferences: prefs,
    );
    await sdk.init(
      const AnalyticsSdkConfig(
        projectId: 'project-5',
        initialRetryDelay: Duration(milliseconds: 10),
        maxRetryDelay: Duration(milliseconds: 20),
        jitterRatio: 0,
      ),
    );

    await sdk.trackEvent('open_feature');
    await sdk.flush();
    await Future<void>.delayed(const Duration(milliseconds: 35));

    expect(calls, greaterThanOrEqualTo(2));
  });

  test('queued events persist between sdk instances', () async {
    int calls = 0;
    final MockClient failingClient = MockClient((http.Request req) async {
      calls += 1;
      throw http.ClientException('offline');
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AnalyticsSdk sdk1 = AnalyticsSdk.test(
      httpClient: failingClient,
      sharedPreferences: prefs,
    );
    await sdk1.init(
      const AnalyticsSdkConfig(
        projectId: 'project-6',
        initialRetryDelay: Duration(milliseconds: 15),
        maxRetryDelay: Duration(milliseconds: 30),
        jitterRatio: 0,
      ),
    );

    await sdk1.trackEvent('persist_me');
    await sdk1.flush();

    final MockClient successClient = MockClient((http.Request req) async {
      calls += 1;
      return http.Response('', 202);
    });

    final AnalyticsSdk sdk2 = AnalyticsSdk.test(
      httpClient: successClient,
      sharedPreferences: prefs,
    );
    await sdk2.init(
      const AnalyticsSdkConfig(
        projectId: 'project-6',
        initialRetryDelay: Duration(milliseconds: 10),
        maxRetryDelay: Duration(milliseconds: 20),
        jitterRatio: 0,
      ),
    );

    await sdk2.flush();

    expect(calls, greaterThanOrEqualTo(2));
  });
}
