import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/di/service_locator.dart';
import '../../models/quote_model.dart';
import '../../services/ninjas_api_service.dart';
import '../widgets/state_views.dart';

/// Экран цитат с фильтрацией по категориям (Quotes)
class QuotesView extends StatefulWidget {
  const QuotesView({super.key});

  @override
  State<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends State<QuotesView> {
  final _apiService = getIt<NinjasApiService>();
  List<QuoteModel> _quotes = [];
  bool _isLoading = false;
  String? _errorMessage;

  int _count = 3;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final quotes = await _apiService.fetchQuotes(count: _count);
      setState(() {
        _quotes = quotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _copyQuote(QuoteModel item) {
    Clipboard.setData(ClipboardData(text: '«${item.quote}» — ${item.author}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Цитата скопирована в буфер обмена!'),
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
              const Icon(Icons.format_quote_rounded, color: Color(0xFF6750A4)),
              const SizedBox(width: 8),
              const Text(
                'Цитаты великих людей',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              const Text('Кол-во: ', style: TextStyle(fontSize: 13)),
              DropdownButton<int>(
                value: _count,
                isDense: true,
                items: [1, 2, 3, 5].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val шт.'),
                  );
                }).toList(),
                onChanged: (newVal) {
                  if (newVal != null && newVal != _count) {
                    setState(() => _count = newVal);
                    _loadQuotes();
                  }
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Список цитат
        Expanded(
          child: _isLoading
              ? const LoadingStateView(message: 'Загружаем цитаты известных людей...')
              : _errorMessage != null
                  ? ErrorStateView(
                      message: _errorMessage!,
                      onRetry: _loadQuotes,
                    )
                  : _quotes.isEmpty
                      ? EmptyStateView(
                          message: 'Цитаты по выбранной теме не найдены',
                          onAction: _loadQuotes,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadQuotes,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _quotes.length,
                            itemBuilder: (context, index) {
                              final item = _quotes[index];
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
                                            label: Text(
                                              item.category.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.copy_rounded, size: 18),
                                            tooltip: 'Скопировать цитату',
                                            onPressed: () => _copyQuote(item),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '«${item.quote}»',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.4,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_pin, size: 18, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              item.author,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
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
