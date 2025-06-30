import 'package:flutter/material.dart';

class IngredientProvider with ChangeNotifier {
  final List<String> _ingredients = [];

  List<String> get ingredients => _ingredients;

  void add(String ingredient) {
    if (!_ingredients.contains(ingredient)) {
      _ingredients.add(ingredient);
      notifyListeners();
    }
  }

  void remove(String ingredient) {
    _ingredients.remove(ingredient);
    notifyListeners();
  }

  void clear() {
    _ingredients.clear();
    notifyListeners();
  }
}
