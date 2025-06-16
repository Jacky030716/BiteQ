import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import the file where ChartData is defined

class CalorieBarChart extends StatelessWidget {
  final List<ChartData> chartData;
  final String selectedTimePeriod;

  const CalorieBarChart({
    super.key,
    required this.chartData,
    required this.selectedTimePeriod,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(selectedTimePeriod),
          gridData: FlGridData(
            show: true,
            horizontalInterval: _getGridInterval(selectedTimePeriod),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(_getLeftAxisLabel(value, selectedTimePeriod));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // For monthly view, show day numbers dynamically
                  if (selectedTimePeriod == 'Month') {
                    // Only show specific day labels to avoid clutter
                    if (value.toInt() == 0 ||
                        (value.toInt() + 1) % 5 == 0 || // Every 5th day
                        (value.toInt() + 1) == chartData.length // Last day
                    ) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          (value.toInt() + 1).toString(), // +1 because index is 0-based
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10, // Smaller font for more labels
                          ),
                        ),
                      );
                    }
                    return const Text(''); // Hide other labels
                  }
                  // For other time periods, use the label from ChartData
                  if (value.toInt() < chartData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        chartData[value.toInt()].label,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: chartData.asMap().entries.map((entry) {
            int index = entry.key;
            ChartData data = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.calories,
                  color: data.isToday
                      ? const Color.fromARGB(255, 55, 74, 218)
                      : Colors.grey.withOpacity(0.3),
                  width: _getBarWidth(selectedTimePeriod, chartData.length),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  double _getMaxY(String timePeriod) {
    switch (timePeriod) {
      case 'Day':
        return 800; // Max for hourly data
      case 'Week':
        return 3000; // Max for daily data
      case 'Month':
        return 3000; // Max for monthly data, adjust if monthly totals are higher
      default:
        return 3000;
    }
  }

  double _getGridInterval(String timePeriod) {
    switch (timePeriod) {
      case 'Day':
        return 200; // 200 calorie intervals for hourly data
      case 'Week':
        return 500; // 500 calorie intervals for daily data
      case 'Month':
        return 500; // 500 calorie intervals for monthly data
      default:
        return 500;
    }
  }

  double _getBarWidth(String timePeriod, int dataLength) {
    switch (timePeriod) {
      case 'Day':
        return 20; // Thinner bars for more data points
      case 'Week':
        return 24; // Medium bars
      case 'Month':
        // Adjust width for monthly view to prevent bars from overlapping
        // A smaller width is needed for 30+ bars
        return 6.0; // Example: a very thin bar for monthly view
      default:
        return 24;
    }
  }

  String _getLeftAxisLabel(double value, String timePeriod) {
    switch (timePeriod) {
      case 'Day':
        if (value == 0) return '0';
        if (value == 200) return '200';
        if (value == 400) return '400';
        if (value == 600) return '600';
        if (value == 800) return '800';
        return '';
      case 'Week':
      case 'Month': // Both Week and Month can use similar Y-axis scaling
        if (value == 0) return '0';
        if (value == 500) return '500';
        if (value == 1000) return '1k';
        if (value == 1500) return '1.5k';
        if (value == 2000) return '2k';
        if (value == 2500) return '2.5k';
        if (value == 3000) return '3k';
        return '';
      default:
        return '';
    }
  }
}