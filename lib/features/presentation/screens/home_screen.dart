import 'package:flutter/material.dart';

import '../widgets/token_dialog.dart';
import 'jokes_view.dart';
import 'quotes_view.dart';
import 'facts_view.dart';
import 'riddles_view.dart';

/// Главный экран приложения с навигацией по вкладкам и панелью диагностики
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<Widget> _views = const [
    JokesView(),
    QuotesView(),
    FactsView(),
    RiddlesView(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hub_rounded, color: Color(0xFF6750A4)),
            SizedBox(width: 8),
            Text('Ninja Discovery Hub'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_rounded),
            tooltip: 'Настройка API-ключа и Interceptor',
            onPressed: () => TokenDialog.show(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: const Color(0xFF6750A4),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFF6750A4),
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.mood_rounded), text: 'Шутки'),
            Tab(icon: Icon(Icons.format_quote_rounded), text: 'Цитаты'),
            Tab(icon: Icon(Icons.lightbulb_rounded), text: 'Факты'),
            Tab(icon: Icon(Icons.psychology_rounded), text: 'Загадки'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _views,
      ),
    );
  }
}
