class Nutrition {
  final String calories;
  final String protein;
  final String carbs;
  final String fat;

  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory Nutrition.fromMap(Map<String, String> data) {
    return Nutrition(
      calories: data['calories'] ?? '-',
      protein: data['protein'] ?? '-',
      carbs: data['carbs'] ?? '-',
      fat: data['fat'] ?? '-',
    );
  }

  Map<String, String> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}
