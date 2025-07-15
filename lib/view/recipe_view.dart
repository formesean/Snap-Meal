import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:snapmeal/controllers/recipe_controller.dart';
import 'package:snapmeal/models/recipe.dart';
import 'package:snapmeal/widgets/nutrient_tile.dart';

const kPrimaryBlue = Color(0xFF3B82F6);

class RecipeView extends StatefulWidget {
  final List<String> ingredients;

  const RecipeView({super.key, required this.ingredients});

  @override
  State<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  final RecipeController _controller = RecipeController();
  List<Recipe> recipes = [];
  bool isLoading = true;
  bool hasError = false;

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

    try {
      final result = await _controller.fetchRecipes(widget.ingredients);
      setState(() => recipes = result);
    } catch (_) {
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showDetails(Recipe recipe) {
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

  Widget _buildDetailContent(Recipe r) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        r.title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(LucideIcons.clock, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(r.cookTime),
          const SizedBox(width: 16),
          Icon(LucideIcons.users, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text('${r.servings} servings'),
        ],
      ),
      const SizedBox(height: 16),
      const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      ...r.ingredients.map(
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
      ...r.steps.asMap().entries.map(
        (e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: kPrimaryBlue,
                child: Text(
                  '${e.key + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(e.value)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      const Text('Nutrition', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          NutrientTile(
            label: 'Calories',
            value: r.nutrition.calories,
            color: Colors.orange,
          ),
          NutrientTile(
            label: 'Protein',
            value: r.nutrition.protein,
            color: Colors.blue,
          ),
          NutrientTile(
            label: 'Carbs',
            value: r.nutrition.carbs,
            color: Colors.green,
          ),
          NutrientTile(
            label: 'Fat',
            value: r.nutrition.fat,
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
                              'https://spoonacular.com/recipeImages/${r.id}-556x370.jpg',
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
                                '${r.match}% match',
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
                              r.title,
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
                                Text(r.cookTime),
                                const SizedBox(width: 16),
                                Icon(
                                  LucideIcons.users,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text('${r.servings} servings'),
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

// EOF
