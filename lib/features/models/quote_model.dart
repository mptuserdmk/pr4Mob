class QuoteModel {
  final String quote;
  final String author;
  final String category;

  const QuoteModel({
    required this.quote,
    required this.author,
    required this.category,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      quote: (json['quote'] as String?)?.trim() ?? '',
      author: (json['author'] as String?)?.trim() ?? 'Неизвестный автор',
      category: (json['category'] as String?)?.trim() ?? 'Общее',
    );
  }

  Map<String, dynamic> toJson() => {
        'quote': quote,
        'author': author,
        'category': category,
      };
}
