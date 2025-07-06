import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/nutrient_tile.dart';

const kPrimaryBlue = Color(0xFF3B82F6);

class RecipeScreen extends StatelessWidget {
  final List<String> ingredients;

  const RecipeScreen({super.key, required this.ingredients});

  final List<Map<String, dynamic>> mockRecipes = const [
    {
      "name": "Chicken Stir Fry",
      "cookTime": "25 min",
      "servings": 4,
      "ingredients": [
        "Chicken Breast",
        "Bell Peppers",
        "Onions",
        "Garlic",
        "Soy Sauce",
      ],
      "steps": [
        "Heat oil in a large pan over medium-high heat",
        "Add chicken and cook until golden brown",
        "Add vegetables and stir-fry for 5-7 minutes",
        "Add sauce and cook for 2 more minutes",
        "Serve hot over rice",
      ],
      "nutrition": {
        "calories": "320",
        "protein": "28g",
        "carbs": "12g",
        "fat": "18g",
      },
    },
    {
      "name": "Mediterranean Pasta",
      "cookTime": "20 min",
      "servings": 3,
      "ingredients": [
        "Tomatoes",
        "Garlic",
        "Onions",
        "Pasta",
        "Olive Oil",
        "Basil",
      ],
      "steps": [
        "Boil pasta according to package directions",
        "Sauté garlic and onions in olive oil",
        "Add tomatoes and cook until soft",
        "Combine with pasta and fresh basil",
        "Season with salt and pepper",
      ],
      "nutrition": {
        "calories": "280",
        "protein": "12g",
        "carbs": "45g",
        "fat": "8g",
      },
    },
  ];

  List<Map<String, dynamic>> getMatchedRecipes() {
    final lowerIngredients = ingredients.map((e) => e.toLowerCase()).toList();

    return mockRecipes
        .map((recipe) {
          final List<String> recipeIngredients = List<String>.from(
            recipe["ingredients"],
          ).map((i) => i.toLowerCase()).toList();

          final matches = recipeIngredients
              .where((ingredient) => lowerIngredients.contains(ingredient))
              .length;

          final matchPercent = ((matches / recipeIngredients.length) * 100)
              .round();

          return {...recipe, "match": matchPercent};
        })
        .where((r) => r["match"] > 0)
        .toList()
      ..sort((a, b) => b["match"].compareTo(a["match"]));
  }

  void showRecipeDetails(BuildContext context, Map<String, dynamic> recipe) {
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
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe["name"],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(LucideIcons.clock, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(recipe["cookTime"]),
                  const SizedBox(width: 16),
                  Icon(LucideIcons.users, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text("${recipe["servings"]} servings"),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                "Ingredients",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                recipe["ingredients"].length,
                (i) => Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: kPrimaryBlue),
                    const SizedBox(width: 6),
                    Text(recipe["ingredients"][i]),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Steps",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...List.generate(
                recipe["steps"].length,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: kPrimaryBlue,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(recipe["steps"][i])),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Nutrition",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  NutrientTile(
                    label: "Calories",
                    value: recipe["nutrition"]["calories"],
                    color: Colors.orange,
                  ),
                  NutrientTile(
                    label: "Protein",
                    value: recipe["nutrition"]["protein"],
                    color: Colors.blue,
                  ),
                  NutrientTile(
                    label: "Carbs",
                    value: recipe["nutrition"]["carbs"],
                    color: Colors.green,
                  ),
                  NutrientTile(
                    label: "Fat",
                    value: recipe["nutrition"]["fat"],
                    color: Colors.purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetFlow(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final matchedRecipes = getMatchedRecipes();

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
        title: const Text("Recipe Suggestions"),
        actions: [
          TextButton(
            onPressed: () => resetFlow(context),
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: matchedRecipes.isEmpty
          ? const Center(child: Text("😞 No matching recipes found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matchedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = matchedRecipes[index];
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
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Icon(
                              LucideIcons.image,
                              size: 60,
                              color: Colors.grey,
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
                                "${recipe["match"]}% match",
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
                              recipe["name"],
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
                                Text(recipe["cookTime"]),
                                const SizedBox(width: 16),
                                Icon(
                                  LucideIcons.users,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text("${recipe["servings"]} servings"),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  showRecipeDetails(context, recipe),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("View Recipe Details"),
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
