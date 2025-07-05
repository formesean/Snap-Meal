import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'recipe_screen.dart';

class IngredientsScreen extends StatefulWidget {
  final List<String> predictions;
  final List<String>? existingIngredients;

  const IngredientsScreen({
    super.key,
    required this.predictions,
    this.existingIngredients,
  });

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  late List<String> ingredients;

  @override
  void initState() {
    super.initState();

    String capitalize(String text) => text
        .split(' ')
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');

    final topPrediction = widget.predictions.isNotEmpty
        ? capitalize(widget.predictions.first.split(' (').first)
        : null;

    ingredients = [
      if (widget.existingIngredients != null) ...widget.existingIngredients!,
      if (topPrediction != null && topPrediction.isNotEmpty) topPrediction,
    ];
  }

  void removeIngredient(String item) {
    setState(() {
      ingredients.remove(item);
    });
  }

  void reset() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void addMore() {
    Navigator.pop(context, ingredients); // Return current list for re-use
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Detected Ingredients"),
        actions: [
          TextButton(
            onPressed: reset,
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // List of ingredients
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.utensils,
                        size: 20,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Your Ingredients",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...ingredients.map(
                    (item) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(item),
                        trailing: IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.red),
                          onPressed: () => removeIngredient(item),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: ingredients.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipeScreen(),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Find Matching Recipes"),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: addMore,
              icon: const Icon(LucideIcons.plus),
              label: const Text("Add More Ingredients"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
