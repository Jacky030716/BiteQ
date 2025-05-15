import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("BiteQ"),
          backgroundColor: Colors.black,
        ),
        body: const BiteQScreen(),
      ),
    );
  }
}

class BiteQScreen extends StatelessWidget {
  const BiteQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calories Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Consumed 1288 Calories',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.pie_chart),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Nutrients Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _NutrientInfo(label: '32g Protein', value: 'Protein'),
              _NutrientInfo(label: '50g Carbohydrate', value: 'Carbohydrates'),
              _NutrientInfo(label: '60g Fats', value: 'Fats'),
            ],
          ),
          const SizedBox(height: 20),
          // Recently Scanned
          const Text(
            'Recently Scanned',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            itemCount: 4,  // Update based on the actual number of scans
            itemBuilder: (context, index) {
              return const _ScannedItem();
            },
          ),
        ],
      ),
    );
  }
}

class _NutrientInfo extends StatelessWidget {
  final String label;
  final String value;
  
  const _NutrientInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

class _ScannedItem extends StatelessWidget {
  const _ScannedItem();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      child: ListTile(
        leading: Image.asset(
          'assets/chicken_bolognese.jpg', // Add the image asset path here
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: const Text('Chicken Bolognese'),
        subtitle: const Text('275 calories'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text('70g'),
            Text('120g'),
            Text('20g'),
          ],
        ),
      ),
    );
  }
}
