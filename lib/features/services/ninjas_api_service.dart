import 'package:dio/dio.dart';

import '../../core/network/api_endpoints.dart';
import '../models/joke_model.dart';
import '../models/quote_model.dart';
import '../models/fact_model.dart';
import '../models/riddle_model.dart';

/// Исключение для понятного отображения ошибок сети в UI
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

/// Сервис взаимодействия с RESTful API Ninjas через Dio
class NinjasApiService {
  final Dio _dio;

  NinjasApiService(this._dio);

  /// Получение списка шуток
  Future<List<JokeModel>> fetchJokes({int count = 1}) async {
    try {
      if (count <= 1) {
        final response = await _dio.get(ApiEndpoints.dadJokes);
        return _parseList(response.data, (json) => JokeModel.fromJson(json));
      }
      final responses = await Future.wait(
        List.generate(count, (_) => _dio.get(ApiEndpoints.dadJokes)),
      );
      final list = <JokeModel>[];
      for (final resp in responses) {
        list.addAll(_parseList(resp.data, (json) => JokeModel.fromJson(json)));
      }
      return list;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Непредвиденная ошибка при загрузке шуток: $e');
    }
  }

  /// Получение цитат
  Future<List<QuoteModel>> fetchQuotes({int count = 1}) async {
    try {
      if (count <= 1) {
        final response = await _dio.get(ApiEndpoints.quotes);
        return _parseList(response.data, (json) => QuoteModel.fromJson(json));
      }
      final responses = await Future.wait(
        List.generate(count, (_) => _dio.get(ApiEndpoints.quotes)),
      );
      final list = <QuoteModel>[];
      for (final resp in responses) {
        list.addAll(_parseList(resp.data, (json) => QuoteModel.fromJson(json)));
      }
      return list;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Непредвиденная ошибка при загрузке цитат: $e');
    }
  }

  /// Получение интересных фактов
  Future<List<FactModel>> fetchFacts({int count = 1}) async {
    try {
      if (count <= 1) {
        final response = await _dio.get(ApiEndpoints.facts);
        return _parseList(response.data, (json) => FactModel.fromJson(json));
      }
      final responses = await Future.wait(
        List.generate(count, (_) => _dio.get(ApiEndpoints.facts)),
      );
      final list = <FactModel>[];
      for (final resp in responses) {
        list.addAll(_parseList(resp.data, (json) => FactModel.fromJson(json)));
      }
      return list;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Непредвиденная ошибка при загрузке фактов: $e');
    }
  }

  /// Получение загадок
  Future<List<RiddleModel>> fetchRiddles({int count = 1}) async {
    try {
      if (count <= 1) {
        final response = await _dio.get(ApiEndpoints.riddles);
        return _parseList(response.data, (json) => RiddleModel.fromJson(json));
      }
      final responses = await Future.wait(
        List.generate(count, (_) => _dio.get(ApiEndpoints.riddles)),
      );
      final list = <RiddleModel>[];
      for (final resp in responses) {
        list.addAll(_parseList(resp.data, (json) => RiddleModel.fromJson(json)));
      }
      return list;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Непредвиденная ошибка при загрузке загадок: $e');
    }
  }

  /// Универсальный парсинг списков объектов
  List<T> _parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  /// Централизованная обработка ошибок Dio
  ApiException _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Таймаут соединения. Проверьте подключение к интернету.',
          statusCode,
        );
      case DioExceptionType.badResponse:
        if (statusCode == 400) {
          return ApiException(
            'Ошибка 400: Неверные параметры запроса (Bad Request).',
            statusCode,
          );
        } else if (statusCode == 401) {
          return ApiException(
            'Ошибка 401: Неверный или отсутствующий X-Api-Key. Проверьте токен в настройках.',
            statusCode,
          );
        } else if (statusCode == 403) {
          return ApiException(
            'Ошибка 403: Доступ запрещен (возможно, эндпоинт требует платный тариф).',
            statusCode,
          );
        } else if (statusCode == 404) {
          return ApiException(
            'Ошибка 404: Ресурс не найден на сервере api-ninjas.com.',
            statusCode,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ApiException(
            'Ошибка $statusCode: Сервер API Ninjas временно недоступен.',
            statusCode,
          );
        }
        return ApiException(
          'Сервер вернул статус $statusCode: ${error.response?.statusMessage ?? "Неизвестная ошибка"}',
          statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException('Запрос был отменен.', statusCode);
      case DioExceptionType.connectionError:
        return ApiException(
          'Отсутствует интернет-соединение или недоступен хост api-ninjas.com.',
          statusCode,
        );
      default:
        return ApiException(
          'Сетевая ошибка: ${error.message ?? "Проверьте подключение к сети."}',
          statusCode,
        );
    }
  }
}
