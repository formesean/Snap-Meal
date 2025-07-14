import 'package:snapmeal/models/nutrition.dart';

class Recipe {
  final int id;
  final String title;
  final String cookTime;
  final int servings;
  final List<String> ingredients;
  final List<String> steps;
  final Nutrition nutrition;
  final int match;

  Recipe({
    required this.id,
    required this.title,
    required this.cookTime,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    required this.match,
  });
}

// EOF
