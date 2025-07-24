import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:snapmeal/view/recipe_view.dart';

const kPrimaryBlue = Color(0xFF3B82F6);

class IngredientView extends StatefulWidget {
  final List<String> predictions;
  final List<String>? existingIngredients;
  final void Function()? onReset;

  const IngredientView({
    super.key,
    required this.predictions,
    this.existingIngredients,
    this.onReset,
  });

  @override
  State<IngredientView> createState() => _IngredientViewState();
}

class _IngredientViewState extends State<IngredientView> {
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
    if (widget.onReset != null) {
      widget.onReset!();
    }
  }

  void addMore() {
    Navigator.pop(context, ingredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Detected Ingredients",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                if (widget.onReset != null) {
                  widget.onReset!();
                }
              },
              child: const Text("Reset", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.utensils, size: 20, color: kPrimaryBlue),
                      SizedBox(width: 8),
                      Text(
                        "Your Ingredients",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (ingredients.isEmpty)
                    const Text(
                      "No ingredients yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ...ingredients.map(
                    (item) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          item,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: ingredients.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeView(ingredients: ingredients),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                side: const BorderSide(color: kPrimaryBlue, width: 2),
                foregroundColor: kPrimaryBlue,
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

// EOF
