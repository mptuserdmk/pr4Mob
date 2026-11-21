# Отчет по практической работе №4
## Дисциплина: МДК 01.03 «Разработка мобильных приложений»
### Тема: «Работа с сетью при помощи пакета Dio. Перехватчики (Interceptors) и внедрение зависимостей (GetIt)»

---

## 1. Цель работы
Изучение механизмов сетевого взаимодействия в Flutter с использованием библиотеки `Dio`, реализация пользовательских перехватчиков (`Interceptor`) для централизованной авторизации и логирования, использование `PrettyDioLogger` для форматированной сетевой телеметрии, а также внедрение сервис-локатора `GetIt` для управления жизненным циклом зависимостей.

---

## 2. Выполнение требований ТЗ (Оценка 5)

| Требование ТЗ | Реализация в проекте | Файл/Компонент |
|---|---|---|
| **Работа с сетью через Dio (на оценку 3)** | Конфигурация клиента с базовым URL, таймаутами и обработкой исключений `DioException`. | `lib/core/di/service_locator.dart`, `lib/features/services/ninjas_api_service.dart` |
| **Interceptor для добавления токена (на оценку 4)** | Создан класс `AuthInterceptor`, внедряющий заголовок `X-Api-Key` во все исходящие запросы в `onRequest`. | `lib/core/network/auth_interceptor.dart` |
| **Логирование через pretty_dio_logger (на оценку 4)** | Интегрирован `PrettyDioLogger` с выводом структурированного JSON, заголовков и ошибок в терминал. | `lib/core/di/service_locator.dart` |
| **Управление зависимостями через get_it (на оценку 5)** | Зарегистрированы `TokenManager`, `Dio`, `NinjasApiService` как Lazy Singletons. | `lib/core/di/service_locator.dart` |
| **Интеграция с https://api-ninjas.com** | Подключены эндпоинты `dadjokes`, `quotes`, `facts`, `riddles`. | `lib/features/services/ninjas_api_service.dart` |
| **Развитая функциональность («не две кнопки»)** | Интерактивный хаб из 4 модулей: шутки, цитаты, факты, загадки со спойлерами ответов, копирование в буфер, pull-to-refresh, диалог управления токеном и симуляции ошибки 401. | `lib/features/presentation/screens/` |

---

## 3. Архитектура приложения

Проект организован по принципам Clean Architecture и разделен на слои:

- **Core Network (`lib/core/network/`)**:
  - `api_endpoints.dart`: Базовый URL `https://api.api-ninjas.com/v1/` и пути эндпоинтов.
  - `token_manager.dart`: Хранилище токена в runtime с возможностью динамической смены.
  - `auth_interceptor.dart`: Перехватчик запросов, автоматически добавляющий `X-Api-Key`.
  - `logging_interceptor.dart`: Кастомный перехватчик из лекции для логирования `onRequest/onResponse/onError`.
- **Core DI (`lib/core/di/`)**:
  - `service_locator.dart`: Конфигурация Service Locator `GetIt`.
- **Features (`lib/features/`)**:
  - `models/`: DTO-модели (`JokeModel`, `QuoteModel`, `FactModel`, `RiddleModel`).
  - `services/`: `NinjasApiService` — выполнение запросов и централизованная обработка сетевых ошибок.
  - `presentation/`:
    - `screens/home_screen.dart`: Главный экран с 4 вкладками.
    - `screens/jokes_view.dart`: Просмотр шуток, выбор количества, копирование.
    - `screens/quotes_view.dart`: Просмотр цитат великих людей.
    - `screens/facts_view.dart`: Научные и исторические факты с pull-to-refresh.
    - `screens/riddles_view.dart`: Загадки с интерактивным раскрытием ответов (spoiler).
    - `widgets/token_dialog.dart`: Окно настроек API-токена с возможностью симуляции 401 Unauthorized.

---

## 4. Ключевые фрагменты кода

### 4.1. Пользовательский Interceptor авторизации (`AuthInterceptor`)
```dart
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor(this._tokenManager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenManager.token;
    if (token.isNotEmpty) {
      options.headers['X-Api-Key'] = token;
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      print('AUTH_INTERCEPTOR: Недействительный токен (401 Unauthorized)');
    }
    super.onError(err, handler);
  }
}
```

### 4.2. Настройка GetIt и сборка перехватчиков Dio
```dart
void setupServiceLocator() {
  getIt.registerLazySingleton<TokenManager>(() => TokenManager());

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(getIt<TokenManager>()),
      LoggingInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    ]);

    return dio;
  });

  getIt.registerLazySingleton<NinjasApiService>(
    () => NinjasApiService(getIt<Dio>()),
  );
}
```

---

## 5. Результаты тестирования

Все модули покрыты юнит- и виджет-тестами в `test/widget_test.dart`:
1. Регистрация сервисов в `GetIt`.
2. Автоматическое добавление заголовка `X-Api-Key` перехватчиком `AuthInterceptor`.
3. Парсинг моделей JSON (`JokeModel`, `QuoteModel`, `FactModel`, `RiddleModel`).
4. Рендеринг пользовательского интерфейса, переключение вкладок и открытие окна настроек токена.

Результат выполнения тестов:
```
All tests passed! (8 passed)
```

---

## 6. Вывод
В ходе выполнения практической работы №4 разработано полнофункциональное кроссплатформенное приложение на Flutter, демонстрирующее современные подходы к архитектуре мобильных приложений:
- Использование `Dio` в качестве мощного HTTP-клиента;
- Применение `Interceptors` для сквозной авторизации и трассировки запросов;
- Использование `GetIt` для инверсии управления и изоляции слоев приложения;
- Обработка сценариев отсутствия сети, таймаутов и кодов ошибок HTTP (400, 401, 403, 404, 500).
