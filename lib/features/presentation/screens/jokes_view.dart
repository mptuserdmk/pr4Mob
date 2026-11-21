import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/di/service_locator.dart';
import '../../models/joke_model.dart';
import '../../services/ninjas_api_service.dart';
import '../widgets/state_views.dart';

/// Экран шуток (Dad Jokes)
class JokesView extends StatefulWidget {
  const JokesView({super.key});

  @override
  State<JokesView> createState() => _JokesViewState();
}

class _JokesViewState extends State<JokesView> {
  final _apiService = getIt<NinjasApiService>();
  List<JokeModel> _jokes = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _limit = 3;

  @override
  void initState() {
    super.initState();
    _loadJokes();
  }

  Future<void> _loadJokes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jokes = await _apiService.fetchJokes(count: _limit);
      setState(() {
        _jokes = jokes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Шутка скопирована в буфер обмена!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Панель управления количеством элементов
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.sentiment_very_satisfied_rounded, color: Color(0xFF6750A4)),
              const SizedBox(width: 8),
              const Text(
                'Батины шутки',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              const Text('Кол-во: ', style: TextStyle(fontSize: 13)),
              DropdownButton<int>(
                value: _limit,
                isDense: true,
                items: [1, 3, 5, 10].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val шт.'),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null && newVal != _limit) {
                    setState(() => _limit = newVal);
                    _loadJokes();
                  }
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Основной контент
        Expanded(
          child: _isLoading
              ? const LoadingStateView(message: 'Загружаем отборные шутки...')
              : _errorMessage != null
                  ? ErrorStateView(
                      message: _errorMessage!,
                      onRetry: _loadJokes,
                    )
                  : _jokes.isEmpty
                      ? EmptyStateView(
                          message: 'Шуток пока нет',
                          onAction: _loadJokes,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadJokes,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _jokes.length,
                            itemBuilder: (context, index) {
                              final item = _jokes[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: const Color(0xFF6750A4).withValues(alpha: 0.1),
                                            radius: 16,
                                            child: const Icon(
                                              Icons.mood,
                                              size: 18,
                                              color: Color(0xFF6750A4),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Шутка #${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.copy_rounded, size: 18),
                                            tooltip: 'Скопировать шутку',
                                            onPressed: () => _copyToClipboard(item.joke),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item.joke,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          'Батя шутит... 🎭',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
