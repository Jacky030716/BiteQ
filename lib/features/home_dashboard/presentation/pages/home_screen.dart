import 'package:biteq/features/home_dashboard/presentation/pages/detail_page.dart';
import 'package:biteq/features/home_dashboard/presentation/widgets/piechart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biteq/features/auth/presentation/viewmodel/sign_out_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signOutViewModel = ref.watch(signOutViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            NavigateButton(route: '/analysis', text: 'Go to Analysis'),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PieChartScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _NutrientCircularChart(
                  label: 'Protein',
                  currentValue: 32,
                  goalValue: 40,
                  color: Colors.orange,
                ),
                _NutrientCircularChart(
                  label: 'Carbohydrate',
                  currentValue: 50,
                  goalValue: 225,
                  color: Colors.yellow,
                ),
                _NutrientCircularChart(
                  label: 'Fats',
                  currentValue: 60,
                  goalValue: 78,
                  color: Colors.green,
                ),
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

class _NutrientCircularChart extends StatelessWidget {
  final String label; // eg 'Protein'
  final int currentValue; // eg 32
  final int goalValue; // eg 40
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
            '$currentValue${label == 'Protein' ? 'g' : ''}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
            builder:
                (context) => DetailPage(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    calories,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        backgroundColor: const Color.fromARGB(255, 99, 97, 97),
      ),
      child: Text(text),
    );
  }
}
