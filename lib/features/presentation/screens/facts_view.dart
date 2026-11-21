import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/di/service_locator.dart';
import '../../models/fact_model.dart';
import '../../services/ninjas_api_service.dart';
import '../widgets/state_views.dart';

/// Экран интересных фактов (Facts)
class FactsView extends StatefulWidget {
  const FactsView({super.key});

  @override
  State<FactsView> createState() => _FactsViewState();
}

class _FactsViewState extends State<FactsView> {
  final _apiService = getIt<NinjasApiService>();
  List<FactModel> _facts = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _limit = 3;

  @override
  void initState() {
    super.initState();
    _loadFacts();
  }

  Future<void> _loadFacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final facts = await _apiService.fetchFacts(count: _limit);
      setState(() {
        _facts = facts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _copyFact(String fact) {
    Clipboard.setData(ClipboardData(text: fact));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Факт скопирован!'),
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
              const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Интересные факты',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              const Text('Лимит: ', style: TextStyle(fontSize: 13)),
              DropdownButton<int>(
                value: _limit,
                isDense: true,
                items: [1, 3, 5, 8].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val шт.'),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null && newVal != _limit) {
                    setState(() => _limit = newVal);
                    _loadFacts();
                  }
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Список фактов
        Expanded(
          child: _isLoading
              ? const LoadingStateView(message: 'Ищем удивительные научные факты...')
              : _errorMessage != null
                  ? ErrorStateView(
                      message: _errorMessage!,
                      onRetry: _loadFacts,
                    )
                  : _facts.isEmpty
                      ? EmptyStateView(
                          message: 'Факты не найдены',
                          onAction: _loadFacts,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadFacts,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _facts.length,
                            itemBuilder: (context, index) {
                              final item = _facts[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.bolt, size: 14, color: Colors.amber.shade900),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'ФАКТ #${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.amber.shade900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.copy_rounded, size: 18),
                                            tooltip: 'Скопировать факт',
                                            onPressed: () => _copyFact(item.fact),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        item.fact,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          height: 1.45,
                                          fontWeight: FontWeight.w400,
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
