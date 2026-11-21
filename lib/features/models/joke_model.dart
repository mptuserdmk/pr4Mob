class JokeModel {
  final String joke;

  const JokeModel({required this.joke});

  factory JokeModel.fromJson(Map<String, dynamic> json) {
    return JokeModel(
      joke: (json['joke'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'joke': joke};
}
