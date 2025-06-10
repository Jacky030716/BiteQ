import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/auth/presentation/viewmodel/sign_out_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';

// Data Models
class FoodItem {
  final String id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final DateTime dateScanned;
  final String imagePath;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.dateScanned,
    this.imagePath = 'assets/images/chicken_bolognese.jpg',
  });

  FoodItem copyWith({
    String? id,
    String? name,
    int? calories,
    double? protein,
    double? carbs,
    double? fats,
    DateTime? dateScanned,
    String? imagePath,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      dateScanned: dateScanned ?? this.dateScanned,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'dateScanned': dateScanned.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fats: json['fats'].toDouble(),
      dateScanned: DateTime.parse(json['dateScanned']),
      imagePath: json['imagePath'] ?? 'assets/images/chicken_bolognese.jpg',
    );
  }
}

// CRUD Service
class FoodService {
  final List<FoodItem> _foodItems = [
    FoodItem(
      id: '1',
      name: 'Chicken Bolognese',
      calories: 275,
      protein: 70,
      carbs: 120,
      fats: 20,
      dateScanned: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FoodItem(
      id: '2',
      name: 'Grilled Salmon',
      calories: 350,
      protein: 45,
      carbs: 5,
      fats: 18,
      dateScanned: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    FoodItem(
      id: '3',
      name: 'Vegetable Stir Fry',
      calories: 180,
      protein: 8,
      carbs: 25,
      fats: 7,
      dateScanned: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // CREATE
  Future<void> addFoodItem(FoodItem foodItem) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    _foodItems.insert(0, foodItem);
  }

  // READ
  Future<List<FoodItem>> getAllFoodItems() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
    return List.from(_foodItems);
  }

  Future<FoodItem?> getFoodItemById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate API call
    try {
      return _foodItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // UPDATE
  Future<void> updateFoodItem(FoodItem updatedItem) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    final index = _foodItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _foodItems[index] = updatedItem;
    }
  }

  // DELETE
  Future<void> deleteFoodItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    _foodItems.removeWhere((item) => item.id == id);
  }

  // Get total nutrition for today
  Future<Map<String, double>> getTodayNutrition() async {
    final today = DateTime.now();
    final todayItems = _foodItems.where((item) => 
      item.dateScanned.day == today.day &&
      item.dateScanned.month == today.month &&
      item.dateScanned.year == today.year
    ).toList();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final item in todayItems) {
      totalCalories += item.calories;
      totalProtein += item.protein;
      totalCarbs += item.carbs;
      totalFats += item.fats;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }
}

// Riverpod Providers
final foodServiceProvider = Provider<FoodService>((ref) => FoodService());

final foodItemsProvider = FutureProvider<List<FoodItem>>((ref) async {
  final foodService = ref.watch(foodServiceProvider);
  return await foodService.getAllFoodItems();
});

final todayNutritionProvider = FutureProvider<Map<String, double>>((ref) async {
  final foodService = ref.watch(foodServiceProvider);
  return await foodService.getTodayNutrition();
});

// State notifier for managing food items
class FoodItemsNotifier extends StateNotifier<AsyncValue<List<FoodItem>>> {
  final FoodService _foodService;

  FoodItemsNotifier(this._foodService) : super(const AsyncValue.loading()) {
    loadFoodItems();
  }

  Future<void> loadFoodItems() async {
    try {
      final items = await _foodService.getAllFoodItems();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addFoodItem(FoodItem item) async {
    try {
      await _foodService.addFoodItem(item);
      await loadFoodItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateFoodItem(FoodItem item) async {
    try {
      await _foodService.updateFoodItem(item);
      await loadFoodItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteFoodItem(String id) async {
    try {
      await _foodService.deleteFoodItem(id);
      await loadFoodItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final foodItemsNotifierProvider = StateNotifierProvider<FoodItemsNotifier, AsyncValue<List<FoodItem>>>((ref) {
  final foodService = ref.watch(foodServiceProvider);
  return FoodItemsNotifier(foodService);
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signOutViewModel = ref.watch(signOutViewModelProvider.notifier);
    final foodItemsAsync = ref.watch(foodItemsNotifierProvider);
    final todayNutritionAsync = ref.watch(todayNutritionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              width: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            const Text('BiteQ'),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 172, 170, 170),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddFoodDialog(context, ref);
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              signOutViewModel.signOut(() => context.go('/sign-in'), ref);
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today • Yesterday',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Nutrition Summary Card
            todayNutritionAsync.when(
              data: (nutrition) => Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Consumed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${nutrition['calories']?.toInt() ?? 0} Calories',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.pie_chart,
                        size: 40,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PieChartScreen(nutrition: nutrition),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 20),
            // Nutrient Charts
            todayNutritionAsync.when(
              data: (nutrition) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutrientCircularChart(
                    label: 'Protein',
                    currentValue: nutrition['protein']?.toInt() ?? 0,
                    goalValue: 150,
                    color: Colors.orange,
                  ),
                  _NutrientCircularChart(
                    label: 'Carbohydrate',
                    currentValue: nutrition['carbs']?.toInt() ?? 0,
                    goalValue: 225,
                    color: Colors.yellow,
                  ),
                  _NutrientCircularChart(
                    label: 'Fats',
                    currentValue: nutrition['fats']?.toInt() ?? 0,
                    goalValue: 78,
                    color: Colors.green,
                  ),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recently Scanned',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Food Items List
            Expanded(
              child: foodItemsAsync.when(
                data: (foodItems) => ListView.builder(
                  itemCount: foodItems.length,
                  itemBuilder: (context, index) {
                    final foodItem = foodItems[index];
                    return _ScannedItem(
                      foodItem: foodItem,
                      onEdit: () => _showEditFoodDialog(context, ref, foodItem),
                      onDelete: () => _showDeleteConfirmation(context, ref, foodItem),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AddEditFoodDialog(
        onSave: (foodItem) {
          ref.read(foodItemsNotifierProvider.notifier).addFoodItem(foodItem);
        },
      ),
    );
  }

  void _showEditFoodDialog(BuildContext context, WidgetRef ref, FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (context) => AddEditFoodDialog(
        foodItem: foodItem,
        onSave: (updatedItem) {
          ref.read(foodItemsNotifierProvider.notifier).updateFoodItem(updatedItem);
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, FoodItem foodItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food Item'),
        content: Text('Are you sure you want to delete "${foodItem.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(foodItemsNotifierProvider.notifier).deleteFoodItem(foodItem.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddEditFoodDialog extends StatefulWidget {
  final FoodItem? foodItem;
  final Function(FoodItem) onSave;

  const AddEditFoodDialog({
    super.key,
    this.foodItem,
    required this.onSave,
  });

  @override
  State<AddEditFoodDialog> createState() => _AddEditFoodDialogState();
}

class _AddEditFoodDialogState extends State<AddEditFoodDialog> {
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem?.name ?? '');
    _caloriesController = TextEditingController(text: widget.foodItem?.calories.toString() ?? '');
    _proteinController = TextEditingController(text: widget.foodItem?.protein.toString() ?? '');
    _carbsController = TextEditingController(text: widget.foodItem?.carbs.toString() ?? '');
    _fatsController = TextEditingController(text: widget.foodItem?.fats.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.foodItem != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Food Item' : 'Add Food Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Food Name'),
            ),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _proteinController,
              decoration: const InputDecoration(labelText: 'Protein (g)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _carbsController,
              decoration: const InputDecoration(labelText: 'Carbs (g)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _fatsController,
              decoration: const InputDecoration(labelText: 'Fats (g)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final foodItem = FoodItem(
              id: widget.foodItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: _nameController.text,
              calories: int.tryParse(_caloriesController.text) ?? 0,
              protein: double.tryParse(_proteinController.text) ?? 0.0,
              carbs: double.tryParse(_carbsController.text) ?? 0.0,
              fats: double.tryParse(_fatsController.text) ?? 0.0,
              dateScanned: widget.foodItem?.dateScanned ?? DateTime.now(),
            );
            widget.onSave(foodItem);
            Navigator.pop(context);
          },
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }
}

class _NutrientCircularChart extends StatelessWidget {
  final String label;
  final int currentValue;
  final int goalValue;
  final Color color;

  const _NutrientCircularChart({
    required this.label,
    required this.currentValue,
    required this.goalValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = (currentValue / goalValue).clamp(0, 1);

    return CircularPercentIndicator(
      radius: 60,
      lineWidth: 8,
      percent: percent,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${currentValue}g',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text(
            'Consumed',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      progressColor: color,
      backgroundColor: Colors.grey[300]!,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1000,
    );
  }
}

class _ScannedItem extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScannedItem({
    required this.foodItem,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              foodItem: foodItem,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        color: Colors.grey[50],
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              foodItem.imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            foodItem.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('${foodItem.calories} cal', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  const Icon(Icons.pets, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text('${foodItem.protein}g', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  const Icon(Icons.local_pizza, size: 16, color: Colors.yellow),
                  const SizedBox(width: 4),
                  Text('${foodItem.carbs}g', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 10),
                  const Icon(Icons.local_drink, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('${foodItem.fats}g', style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${foodItem.dateScanned.day}/${foodItem.dateScanned.month}/${foodItem.dateScanned.year} | ${foodItem.dateScanned.hour}:${foodItem.dateScanned.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: const Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DetailPage({
    super.key,
    required this.foodItem,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Food Item'),
                  content: Text('Are you sure you want to delete "${foodItem.name}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        onDelete();
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Go back to home
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              foodItem.imagePath,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              foodItem.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Calories: ${foodItem.calories}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Protein: ${foodItem.protein}g', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Carbs: ${foodItem.carbs}g', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Fats: ${foodItem.fats}g', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              'Date: ${foodItem.dateScanned.day}/${foodItem.dateScanned.month}/${foodItem.dateScanned.year} | ${foodItem.dateScanned.hour}:${foodItem.dateScanned.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            NavigateButton(route: '/explore', text: 'Explore'),
          ],
        ),
      ),
    );
  }
}

class NavigateButton extends StatelessWidget {
  final String route;
  final String text;

  const NavigateButton({super.key, required this.route, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go(route);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 99, 97, 97),
      ),
      child: Text(text),
    );
  }
}

class PieChartScreen extends StatelessWidget {
  final Map<String, double> nutrition;

  const PieChartScreen({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    final proteinCalories = (nutrition['protein'] ?? 0) * 4;
    final carbCalories = (nutrition['carbs'] ?? 0) * 4;
    final fatCalories = (nutrition['fats'] ?? 0) * 9;

    final dataMap = <String, double>{
      "Protein": proteinCalories,
      "Carbohydrate": carbCalories,
      "Fats": fatCalories,
    };

    final colorList = <Color>[
      Colors.orange,
      Colors.yellow,
      Colors.green,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Breakdown Pie Chart'),
      ),
      body: Center(
        child: PieChart(
          dataMap: dataMap,
          animationDuration: const Duration(milliseconds: 800),
          chartRadius: MediaQuery.of(context).size.width / 1.5,
          colorList: colorList,
          chartType: ChartType.disc,
          ringStrokeWidth: 32,
          centerText: "Calories",
          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValuesInPercentage: true,
            decimalPlaces: 1,
            showChartValuesOutside: false,
          ),
        ),
      ),
    );
  }
}