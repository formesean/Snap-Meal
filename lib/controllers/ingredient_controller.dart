class IngredientController {
  List<String> ingredients = [];

  void initialize(List<String>? existing, List<String> predictions) {
    String capitalize(String text) => text
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');

    final topPrediction = predictions.isNotEmpty
        ? capitalize(predictions.first.split(' (').first)
        : null;

    ingredients = [
      if (existing != null) ...existing,
      if (topPrediction != null && topPrediction.isNotEmpty) topPrediction,
    ];
  }

  void remove(String item) {
    ingredients.remove(item);
  }
}

// EOF
