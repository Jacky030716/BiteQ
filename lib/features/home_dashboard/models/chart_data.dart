// Chart data for different time periods
class ChartData {
  final String label;
  final double calories;
  final bool isToday;

  ChartData({
    required this.label,
    required this.calories,
    this.isToday = false,
  });
}
