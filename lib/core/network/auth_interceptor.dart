import 'package:dio/dio.dart';
import 'token_manager.dart';

/// Пользовательский перехватчик (Interceptor) для автоматического
/// добавления токена авторизации (X-Api-Key) в заголовок запроса
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
      // ignore: avoid_print
      print('AUTH_INTERCEPTOR: Недействительный или отсутствующий токен авторизации (401 Unauthorized)');
    }
    super.onError(err, handler);
  }
}
