# analytics_package

Flutter SDK для отправки аналитических событий в backend с гарантией доставки через персистентную очередь и retry.

## Что теперь умеет SDK

- Автоопределяет `platform` (`android | ios | web`)
- Автоматически создает и хранит `user_id` в `SharedPreferences`
- Позволяет вручную переопределить `user_id` через `setUserId(...)`
- Работает как singleton через статический API `Analytics.*`

## Публичный API

- `Analytics.init(config)`
- `Analytics.setUserId(userId)`
- `Analytics.trackOpenApp()`
- `Analytics.trackEvent(eventName)`
- `Analytics.trackNumber(eventName, value)`
- `Analytics.flush()`
- `Analytics.setEnabled(bool)`
- `Analytics.shutdown()`

## Установка

Добавьте пакет в `pubspec.yaml` приложения:

```yaml
dependencies:
  analytics_package:
    path: ../analytics_package
```

## Интеграция в приложение (минимум)

После этого не нужно передавать `platform` и `userId` в каждый вызов:

```dart
import 'package:analytics_package/analytics_package.dart';

Future<void> setupAnalytics() async {
  await Analytics.init(
    const AnalyticsSdkConfig(
      projectId: 'my_project_id',
      baseUrl: 'http://localhost:8080',
    ),
  );
}

Future<void> onAppOpened() => Analytics.trackOpenApp();
Future<void> onClick() => Analytics.trackEvent('button_clicked');
Future<void> onAmount(double value) => Analytics.trackNumber('amount_changed', value);
```

## Как формируется `user_id`

1. При первом `init` SDK генерирует анонимный ID (`anon_...`).
2. ID сохраняется в `SharedPreferences`.
3. На следующих запусках используется тот же ID.
4. Если нужно привязать к аккаунту пользователя:

```dart
await Analytics.setUserId('u_123');
```

Этот ID также персистится и будет использоваться дальше.

## Контракт отправки

SDK отправляет `POST /sdk/projects/:projectId/events` с `Content-Type: application/json`.

Обязательные поля:
- `user_id: string`
- `event: string`
- `platform: "android" | "ios" | "web"`

Опциональные поля:
- `value: number` (только для number-метрик)
- `occurred_at: string` (ISO-8601 UTC)

## Надежность доставки

- FIFO очередь
- Персистентная очередь (`SharedPreferences`)
- Retry только для `network`/`5xx`
- Для `4xx` retry не выполняется
- Exponential backoff + jitter

## Конфигурация

`AnalyticsSdkConfig`:
- `projectId` (required)
- `baseUrl` (default: `http://localhost:8080`)
- `requestTimeout` (default: `10s`)
- `initialRetryDelay` (default: `1s`)
- `maxRetryDelay` (default: `1m`)
- `jitterRatio` (default: `0.2`)
- `enabledByDefault` (default: `true`)

## Важно для localhost

- На Android emulator обычно нужен `http://10.0.2.2:8080`
- На реальных устройствах `localhost` указывает на само устройство
