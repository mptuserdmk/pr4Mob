import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ninjas_api_hub/core/di/service_locator.dart';
import 'package:ninjas_api_hub/core/network/auth_interceptor.dart';
import 'package:ninjas_api_hub/core/network/token_manager.dart';
import 'package:ninjas_api_hub/features/models/fact_model.dart';
import 'package:ninjas_api_hub/features/models/joke_model.dart';
import 'package:ninjas_api_hub/features/models/quote_model.dart';
import 'package:ninjas_api_hub/features/models/riddle_model.dart';
import 'package:ninjas_api_hub/features/services/ninjas_api_service.dart';
import 'package:ninjas_api_hub/main.dart';

/// Фейковый сервис для изоляции виджет-тестов от реальных сетевых вызовов
class FakeNinjasApiService extends NinjasApiService {
  FakeNinjasApiService(super.dio);

  @override
  Future<List<JokeModel>> fetchJokes({int count = 1}) async {
    return [
      const JokeModel(joke: 'Тестовая батина шутка'),
    ];
  }

  @override
  Future<List<QuoteModel>> fetchQuotes({int count = 1}) async {
    return [
      const QuoteModel(
        quote: 'Знания — сила',
        author: 'Фрэнсис Бэкон',
        category: 'knowledge',
      ),
    ];
  }

  @override
  Future<List<FactModel>> fetchFacts({int count = 1}) async {
    return [
      const FactModel(fact: 'Тестовый интересный факт'),
    ];
  }

  @override
  Future<List<RiddleModel>> fetchRiddles({int count = 1}) async {
    return [
      const RiddleModel(
        title: 'Загадка',
        question: 'Зимой и летом одним цветом?',
        answer: 'Ёлка',
      ),
    ];
  }
}

void main() {
  setUp(() {
    setupServiceLocator();
  });

  group('Dependency Injection & Services (GetIt)', () {
    test('GetIt successfully registers TokenManager, Dio, and NinjasApiService', () {
      expect(getIt.isRegistered<TokenManager>(), isTrue);
      expect(getIt.isRegistered<Dio>(), isTrue);
      expect(getIt.isRegistered<NinjasApiService>(), isTrue);
    });

    test('AuthInterceptor automatically injects X-Api-Key into request headers', () {
      final tokenManager = TokenManager(initialToken: 'custom_test_api_key_42');
      final interceptor = AuthInterceptor(tokenManager);

      final options = RequestOptions(path: '/dadjokes');
      interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['X-Api-Key'], equals('custom_test_api_key_42'));
    });
  });

  group('Data Models Deserialization (JSON Parsing)', () {
    test('JokeModel parsed correctly', () {
      final json = {'joke': 'Why do programmers prefer dark mode? Because light attracts bugs.'};
      final model = JokeModel.fromJson(json);
      expect(model.joke, equals('Why do programmers prefer dark mode? Because light attracts bugs.'));
      expect(model.toJson()['joke'], equals(model.joke));
    });

    test('QuoteModel parsed correctly', () {
      final json = {
        'quote': 'Stay hungry, stay foolish.',
        'author': 'Steve Jobs',
        'category': 'success'
      };
      final model = QuoteModel.fromJson(json);
      expect(model.quote, equals('Stay hungry, stay foolish.'));
      expect(model.author, equals('Steve Jobs'));
      expect(model.category, equals('success'));
    });

    test('FactModel parsed correctly', () {
      final json = {'fact': 'Honey never spoils.'};
      final model = FactModel.fromJson(json);
      expect(model.fact, equals('Honey never spoils.'));
    });

    test('RiddleModel parsed correctly', () {
      final json = {
        'title': 'Echo',
        'question': 'I speak without a mouth and hear without ears. What am I?',
        'answer': 'An echo'
      };
      final model = RiddleModel.fromJson(json);
      expect(model.title, equals('Echo'));
      expect(model.question, contains('without a mouth'));
      expect(model.answer, equals('An echo'));
    });
  });

  group('Presentation & UI Widget Tests', () {
    setUp(() {
      // Регистрируем фейковый сервис для стабильных тестов
      if (getIt.isRegistered<NinjasApiService>()) {
        getIt.unregister<NinjasApiService>();
      }
      getIt.registerLazySingleton<NinjasApiService>(
        () => FakeNinjasApiService(getIt<Dio>()),
      );
    });

    testWidgets('HomeScreen renders AppBar with title, actions, and TabBar', (WidgetTester tester) async {
      await tester.pumpWidget(const NinjasHubApp());
      await tester.pumpAndSettle();

      expect(find.text('Ninja Discovery Hub'), findsOneWidget);
      expect(find.byIcon(Icons.vpn_key_rounded), findsOneWidget);
      expect(find.text('Шутки'), findsOneWidget);
      expect(find.text('Цитаты'), findsOneWidget);
      expect(find.text('Факты'), findsOneWidget);
      expect(find.text('Загадки'), findsOneWidget);

      // Проверяем отображение контента первой вкладки
      expect(find.text('Тестовая батина шутка'), findsOneWidget);
    });

    testWidgets('Tapping key button opens Token & Diagnostic dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const NinjasHubApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.vpn_key_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Настройки API-ключа'), findsOneWidget);
      expect(find.text('Сбросить ключ'), findsOneWidget);
      expect(find.text('Тест 401 (Bad Key)'), findsOneWidget);
    });
  });
}
