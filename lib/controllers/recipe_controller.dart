import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:snapmeal/models/nutrition.dart';
import 'package:snapmeal/models/recipe.dart';

class RecipeController {
  final spoonacularKey = dotenv.env['SPOONACULAR_API_KEY'];

  Future<List<Recipe>> fetchRecipes(List<String> ingredients) async {
    if (spoonacularKey == null) {
      throw Exception('❌ Spoonacular API key is missing in .env file');
    }

    final query = ingredients.join(',+');
    final url = Uri.https('api.spoonacular.com', '/recipes/findByIngredients', {
      'ingredients': query,
      'number': '10',
      'ranking': '1',
      'apiKey': spoonacularKey,
    });

    final resp = await http.get(url);
    if (resp.statusCode != 200) throw Exception('API Error');

    final List data = jsonDecode(resp.body);

    final futures = data.map((r) async {
      final id = r['id'];
      final infoUrl = Uri.https(
        'api.spoonacular.com',
        '/recipes/$id/information',
        {'includeNutrition': 'true', 'apiKey': spoonacularKey},
      );
      final infoRes = await http.get(infoUrl);
      final info = jsonDecode(infoRes.body);
      final used = (r['usedIngredientCount'] as int);
      final total = used + (r['missedIngredientCount'] as int);
      final match = ((used / total) * 100).round();

      return Recipe(
        id: id,
        title: info['title'],
        cookTime: '${info['readyInMinutes']} min',
        servings: info['servings'],
        ingredients: info['extendedIngredients']
            .map<String>((i) => i['original'] as String)
            .toList(),
        steps: info['analyzedInstructions'].isNotEmpty
            ? (info['analyzedInstructions'][0]['steps'] as List)
                  .map<String>((s) => s['step'] as String)
                  .toList()
            : [],
        nutrition: Nutrition(
          calories: _getNutrient(info, 'Calories'),
          protein: _getNutrient(info, 'Protein'),
          carbs: _getNutrient(info, 'Carbohydrates'),
          fat: _getNutrient(info, 'Fat'),
        ),
        match: match,
      );
    }).toList();

    final results = await Future.wait(futures);
    results.sort((a, b) => b.match.compareTo(a.match));
    return results;
  }

  String _getNutrient(Map<String, dynamic> info, String label) {
    try {
      return (info['nutrition']['nutrients'] as List)
          .firstWhere((n) => n['name'] == label)['amount']
          .toStringAsFixed(0);
    } catch (_) {
      return '-';
    }
  }
}

// EOF
