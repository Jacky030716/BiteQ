import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartScreen extends StatelessWidget {
  const PieChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final proteinGrams = 32;
    final carbGrams = 50;
    final fatGrams = 60;

    // Calculate calories
    final proteinCalories = proteinGrams * 4;
    final carbCalories = carbGrams * 4;
    final fatCalories = fatGrams * 9;

    final dataMap = <String, double>{
      "Protein": proteinCalories.toDouble(),
      "Carbohydrate": carbCalories.toDouble(),
      "Fats": fatCalories.toDouble(),
    };

    final colorList = <Color>[Colors.orange, Colors.yellow, Colors.green];

    return Scaffold(
      appBar: AppBar(title: const Text('Calorie Breakdown Pie Chart')),
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
