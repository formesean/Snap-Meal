# Snap Meal

Snap Meal is a mobile app that streamlines meal planning using computer vision. Users take or upload photos of food ingredients, and the app identifies them using a trained TensorFlow Lite model. The identified items are added to a list, and Snap Meal suggests matching recipes using the Spoonacular API. The goal is to reduce food waste and inspire meal creativity based on what's available.

---

## Features

- **Ingredient Detection**: Uses an on-device TensorFlow Lite model to detect and classify ingredients from images taken via the camera (or selected from the gallery, if supported).
- **Ingredient List Management**: Add, remove, or reset detected ingredients easily. Manage your list before searching for recipes.
- **Recipe Suggestions**: Finds recipes that best match your detected ingredients using the Spoonacular API. Recipes are sorted by how well they match your available ingredients.
- **Meal Details**: View recipe details in a modal popup, including steps, nutrition facts (calories, protein, carbs, fat), and required ingredients.
- **Session Reset**: Reset the ingredient list and start new sessions at any time.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart (comes with Flutter)
- Android Studio or Xcode (for mobile emulation or deployment)

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/snapmeal.git
   cd snapmeal
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the app:**
   ```bash
   flutter run
   ```

---

## Usage
- Open the app and use the camera to add food ingredient images.
- Review and manage your detected ingredient list (add, remove, reset).
- Tap "Find Matching Recipes" to get meal ideas based on your ingredients.
- View recipe details, including steps and nutrition facts, in a modal popup.
- Reset the session to start over with new ingredients.

---

## Contributing
Contributions are welcome! Please open issues or submit pull requests for improvements and bug fixes.

---

## License
[MIT](LICENSE)
