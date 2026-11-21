import 'package:flutter/foundation.dart';

/// Менеджер хранения и обновления API-ключа в runtime
class TokenManager extends ChangeNotifier {
  // Ключ из лекционных материалов
  static const String defaultKey = 'WxFex5bq8wtHWgVxgTjXc2ztZT2sf9baY2NLzgQe';

  String _token;

  TokenManager({String initialToken = defaultKey}) : _token = initialToken;

  String get token => _token;

  void updateToken(String newToken) {
    _token = newToken.trim();
    notifyListeners();
  }

  void resetToDefault() {
    _token = defaultKey;
    notifyListeners();
  }
}
