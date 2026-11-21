import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../network/api_endpoints.dart';
import '../network/auth_interceptor.dart';
import '../network/logging_interceptor.dart';
import '../network/token_manager.dart';
import '../../features/services/ninjas_api_service.dart';

final getIt = GetIt.instance;

/// Настройка Dependency Injection через GetIt (требование на оценку 5)
void setupServiceLocator() {
  // 1. Менеджер токена
  if (!getIt.isRegistered<TokenManager>()) {
    getIt.registerLazySingleton<TokenManager>(() => TokenManager());
  }

  // 2. Экземпляр Dio с интерсепторами
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          responseType: ResponseType.json,
        ),
      );

      // Добавление перехватчиков (авторизация + кастомный логгер + PrettyDioLogger)
      dio.interceptors.addAll([
        AuthInterceptor(getIt<TokenManager>()),
        LoggingInterceptor(),
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      ]);

      return dio;
    });
  }

  // 3. Сервис для выполнения API-запросов
  if (!getIt.isRegistered<NinjasApiService>()) {
    getIt.registerLazySingleton<NinjasApiService>(
      () => NinjasApiService(getIt<Dio>()),
    );
  }
}
