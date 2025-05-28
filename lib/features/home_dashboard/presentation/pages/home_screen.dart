import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/auth/presentation/viewmodel/sign_out_view_model.dart';
import 'package:go_router/go_router.dart';

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
            Container(
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
                    children: const [
                      Text(
                        'Consumed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '1288 Calories',
                        style: TextStyle(
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
                      // Pie chart action
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _NutrientInfo(label: '32g', description: 'Protein'),
                _NutrientInfo(label: '50g', description: 'Carbohydrate'),
                _NutrientInfo(label: '60g', description: 'Fats'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recently Scanned',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return _ScannedItem(
                    foodName: 'Chicken Bolognese',
                    calories: '275 calories',
                    protein: '70g',
                    carbs: '120g',
                    fats: '20g',
                    date: '23 Mar 2025 | 12:57pm',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientInfo extends StatelessWidget {
  final String label;
  final String description;

  const _NutrientInfo({required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.27,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Consumed',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ScannedItem extends StatelessWidget {
  final String foodName;
  final String calories;
  final String protein;
  final String carbs;
  final String fats;
  final String date;

  const _ScannedItem({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              foodName: foodName,
              calories: calories,
              protein: protein,
              carbs: carbs,
              fats: fats,
              date: date,
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
              'assets/images/chicken_bolognese.jpg',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            foodName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_fire_department, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(calories, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 20),
                  Icon(Icons.pets, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(protein, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 20),
                  Icon(Icons.local_pizza, size: 16, color: Colors.yellow),
                  const SizedBox(width: 4),
                  Text(carbs, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 20),
                  Icon(Icons.local_drink, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(fats, style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String foodName;
  final String calories;
  final String protein;
  final String carbs;
  final String fats;
  final String date;

  const DetailPage({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/chicken_bolognese.jpg',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              foodName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Calories: $calories', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Protein: $protein', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Carbs: $carbs', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Fats: $fats', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Date: $date', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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

  const NavigateButton({required this.route, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go(route); // Use GoRouter to navigate
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.blue,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
