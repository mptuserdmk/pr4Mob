class FactModel {
  final String fact;

  const FactModel({required this.fact});

  factory FactModel.fromJson(Map<String, dynamic> json) {
    return FactModel(
      fact: (json['fact'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'fact': fact};
}
