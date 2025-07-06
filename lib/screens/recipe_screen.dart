import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import '../widgets/nutrient_tile.dart';

const kPrimaryBlue = Color(0xFF3B82F6);
const spoonacularKey = '921fa3e9ddb54a4a8eeafe8f7d0da663';

class RecipeScreen extends StatefulWidget {
  final List<String> ingredients;

  const RecipeScreen({super.key, required this.ingredients});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true, hasError = false;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final query = widget.ingredients.join(',+');
    final url = Uri.https('api.spoonacular.com', '/recipes/findByIngredients', {
      'ingredients': query,
      'number': '10',
      'ranking': '1',
      'apiKey': spoonacularKey,
    });

    try {
      final resp = await http.get(url);
      if (resp.statusCode != 200) throw Exception('API error');
      final List data = jsonDecode(resp.body);

      // Fetch full info & nutrition for each recipe
      final futures = data.map((r) async {
        final id = r['id'];
        final infoUrl = Uri.https(
          'api.spoonacular.com',
          '/recipes/$id/information',
          {'includeNutrition': 'true', 'apiKey': spoonacularKey},
        );
        final infoRes = await http.get(infoUrl);
        if (infoRes.statusCode != 200) throw Exception();
        final info = jsonDecode(infoRes.body);
        final used = (r['usedIngredientCount'] as int);
        final total = (r['missedIngredientCount'] as int) + used;
        final match = ((used / total) * 100).round();
        return {
          'id': id,
          'title': info['title'],
          'cookTime': '${info['readyInMinutes']} min',
          'servings': info['servings'],
          'ingredients': info['extendedIngredients']
              .map<String>((i) => i['original'] as String)
              .toList(),
          'steps': info['analyzedInstructions'].isNotEmpty
              ? (info['analyzedInstructions'][0]['steps'] as List)
                    .map<String>((s) => s['step'] as String)
                    .toList()
              : [],
          'nutrition': {
            'calories': _getNutrient(info, 'Calories'),
            'protein': _getNutrient(info, 'Protein'),
            'carbs': _getNutrient(info, 'Carbohydrates'),
            'fat': _getNutrient(info, 'Fat'),
          },
          'match': match,
        };
      }).toList();

      final results = await Future.wait(futures);
      results.sort((a, b) => b['match'].compareTo(a['match']));

      setState(() {
        recipes = results;
      });
    } catch (e) {
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  void showDetails(Map<String, dynamic> recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFF0F9FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, ctl) => SingleChildScrollView(
          controller: ctl,
          padding: const EdgeInsets.all(16),
          child: _buildDetailContent(recipe),
        ),
      ),
    );
  }

  Widget _buildDetailContent(Map<String, dynamic> r) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        r['title'],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(LucideIcons.clock, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(r['cookTime']),
          const SizedBox(width: 16),
          Icon(LucideIcons.users, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text('${r['servings']} servings'),
        ],
      ),
      const SizedBox(height: 16),
      const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ...r['ingredients'].map<Widget>(
        (i) => Row(
          children: [
            const Icon(Icons.circle, size: 6, color: kPrimaryBlue),
            const SizedBox(width: 6),
            Expanded(child: Text(i)),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const Text('Steps', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ...r['steps'].asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: kPrimaryBlue,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(s)),
            ],
          ),
        );
      }),
      const SizedBox(height: 20),
      const Text('Nutrition', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          NutrientTile(
            label: 'Calories',
            value: r['nutrition']['calories'],
            color: Colors.orange,
          ),
          NutrientTile(
            label: 'Protein',
            value: r['nutrition']['protein'],
            color: Colors.blue,
          ),
          NutrientTile(
            label: 'Carbs',
            value: r['nutrition']['carbs'],
            color: Colors.green,
          ),
          NutrientTile(
            label: 'Fat',
            value: r['nutrition']['fat'],
            color: Colors.purple,
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Recipe Suggestions'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchRecipes),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? const Center(child: Text('Failed to load recipes'))
          : recipes.isEmpty
          ? const Center(child: Text('😞 No matching recipes found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              itemBuilder: (_, i) {
                final r = recipes[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Image.network(
                              'https://spoonacular.com/recipeImages/${r['id']}-556x370.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${r['match']}% match',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.clock,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(r['cookTime']),
                                const SizedBox(width: 16),
                                Icon(
                                  LucideIcons.users,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text('${r['servings']} servings'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => showDetails(r),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('View Recipe Details'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
