import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/di/service_locator.dart';
import '../../models/riddle_model.dart';
import '../../services/ninjas_api_service.dart';
import '../widgets/state_views.dart';

/// Экран загадок со спойлером ответа (Riddles)
class RiddlesView extends StatefulWidget {
  const RiddlesView({super.key});

  @override
  State<RiddlesView> createState() => _RiddlesViewState();
}

class _RiddlesViewState extends State<RiddlesView> {
  final _apiService = getIt<NinjasApiService>();
  List<RiddleModel> _riddles = [];
  final Set<int> _revealedAnswers = {};
  bool _isLoading = false;
  String? _errorMessage;
  int _limit = 3;

  @override
  void initState() {
    super.initState();
    _loadRiddles();
  }

  Future<void> _loadRiddles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _revealedAnswers.clear();
    });

    try {
      final riddles = await _apiService.fetchRiddles(count: _limit);
      setState(() {
        _riddles = riddles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleAnswer(int index) {
    setState(() {
      if (_revealedAnswers.contains(index)) {
        _revealedAnswers.remove(index);
      } else {
        _revealedAnswers.add(index);
      }
    });
  }

  void _copyRiddle(RiddleModel item) {
    Clipboard.setData(ClipboardData(text: 'Загадка: ${item.question}\nОтвет: ${item.answer}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Загадка и ответ скопированы!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Панель параметров
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Загадки и ребусы',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              const Text('Лимит: ', style: TextStyle(fontSize: 13)),
              DropdownButton<int>(
                value: _limit,
                isDense: true,
                items: [1, 3, 5].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val шт.'),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null && newVal != _limit) {
                    setState(() => _limit = newVal);
                    _loadRiddles();
                  }
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Список загадок
        Expanded(
          child: _isLoading
              ? const LoadingStateView(message: 'Загружаем интересные загадки...')
              : _errorMessage != null
                  ? ErrorStateView(
                      message: _errorMessage!,
                      onRetry: _loadRiddles,
                    )
                  : _riddles.isEmpty
                      ? EmptyStateView(
                          message: 'Загадки не найдены',
                          onAction: _loadRiddles,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadRiddles,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _riddles.length,
                            itemBuilder: (context, index) {
                              final item = _riddles[index];
                              final isRevealed = _revealedAnswers.contains(index);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Chip(
                                            visualDensity: VisualDensity.compact,
                                            avatar: const Icon(Icons.psychology, size: 16),
                                            label: Text(
                                              item.title.isNotEmpty ? item.title : 'Загадка #${index + 1}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.copy_rounded, size: 18),
                                            tooltip: 'Скопировать загадку',
                                            onPressed: () => _copyRiddle(item),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        item.question,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      // Спойлер ответа
                                      InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () => _toggleAnswer(index),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isRevealed ? Colors.teal.shade50 : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isRevealed ? Colors.teal.shade200 : Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                isRevealed ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                                size: 18,
                                                color: isRevealed ? Colors.teal.shade700 : Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  isRevealed
                                                      ? 'Ответ: ${item.answer}'
                                                      : 'Нажмите, чтобы увидеть ответ',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: isRevealed ? FontWeight.bold : FontWeight.normal,
                                                    color: isRevealed ? Colors.teal.shade900 : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
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
