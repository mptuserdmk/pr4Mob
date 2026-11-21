import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/token_manager.dart';

/// Диалог настройки API-токена и сетевой диагностики
class TokenDialog extends StatefulWidget {
  const TokenDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const TokenDialog(),
    );
  }

  @override
  State<TokenDialog> createState() => _TokenDialogState();
}

class _TokenDialogState extends State<TokenDialog> {
  late final TextEditingController _controller;
  final _tokenManager = getIt<TokenManager>();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _tokenManager.token);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveToken() {
    _tokenManager.updateToken(_controller.text);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API-токен успешно обновлен в AuthInterceptor!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _simulateInvalidToken() {
    _controller.text = 'invalid_dummy_token_12345';
    _tokenManager.updateToken(_controller.text);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.deepOrange,
        content: Text('Установлен неверный токен для симуляции ошибки 401 Unauthorized'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetDefault() {
    _tokenManager.resetToDefault();
    _controller.text = _tokenManager.token;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Восстановлен ключ по умолчанию из лекции'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.key_rounded, color: Color(0xFF6750A4)),
          SizedBox(width: 8),
          Text('Настройки API-ключа', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Токен автоматически внедряется в каждый запрос через пользовательский AuthInterceptor (заголовок X-Api-Key).',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'X-Api-Key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _resetDefault,
                  icon: const Icon(Icons.restore_rounded, size: 16),
                  label: const Text('Сбросить ключ'),
                ),
                OutlinedButton.icon(
                  onPressed: _simulateInvalidToken,
                  icon: const Icon(Icons.bug_report_rounded, size: 16, color: Colors.deepOrange),
                  label: const Text('Тест 401 (Bad Key)'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _saveToken,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
