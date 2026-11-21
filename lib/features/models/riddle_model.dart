class RiddleModel {
  final String title;
  final String question;
  final String answer;

  const RiddleModel({
    required this.title,
    required this.question,
    required this.answer,
  });

  factory RiddleModel.fromJson(Map<String, dynamic> json) {
    return RiddleModel(
      title: (json['title'] as String?)?.trim() ?? 'Загадка',
      question: (json['question'] as String?)?.trim() ?? '',
      answer: (json['answer'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'question': question,
        'answer': answer,
      };
}
