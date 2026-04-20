class Exercise {
  final String id;
  final String name;
  final String target;
  final String bodyPart;

  const Exercise({
    required this.id,
    required this.name,
    required this.target,
    required this.bodyPart,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      target: (json['target'] ?? '').toString(),
      bodyPart: (json['bodyPart'] ?? '').toString(),
    );
  }
}
