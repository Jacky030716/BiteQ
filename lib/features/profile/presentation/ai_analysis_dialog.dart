import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard

// Function to show the AI Analysis dialog
void showAiAnalysisDialog(
  BuildContext context,
  String notes,
  int? protein,
  int? carbs,
  int? fat,
  int? calories,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.blue.shade600,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Your Personalized AI Analysis',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Analysis Notes
                      Text(
                        notes,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black87,
                          height: 1.5,
                          fontSize: 16,
                        ),
                      ),
                      if (protein != null ||
                          carbs != null ||
                          fat != null ||
                          calories != null) ...[
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          'Recommended Daily Macros:',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Displaying Macros
                        if (calories != null)
                          _buildMacroRow(
                            context,
                            'Calories',
                            '$calories kcal',
                            Icons.local_fire_department,
                          ),
                        if (protein != null)
                          _buildMacroRow(
                            context,
                            'Protein',
                            '$protein g',
                            Icons.egg_alt,
                          ),
                        if (carbs != null)
                          _buildMacroRow(
                            context,
                            'Carbs',
                            '$carbs g',
                            Icons.bakery_dining,
                          ),
                        if (fat != null)
                          _buildMacroRow(
                            context,
                            'Fat',
                            '$fat g',
                            Icons.oil_barrel,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: () {
                      final fullTextToCopy =
                          """
AI Analysis:
$notes

Recommended Daily Macros:
${calories != null ? 'Calories: $calories kcal\n' : ''}
${protein != null ? 'Protein: $protein g\n' : ''}
${carbs != null ? 'Carbs: $carbs g\n' : ''}
${fat != null ? 'Fat: $fat g\n' : ''}
                      """.trim();
                      Clipboard.setData(
                        ClipboardData(text: fullTextToCopy),
                      ).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Analysis copied to clipboard!',
                            ),
                            backgroundColor: Colors.green.shade400,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.all(10),
                          ),
                        );
                      });
                    },
                    icon: Icon(Icons.copy, color: Colors.blue.shade600),
                    label: Text(
                      'Copy',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue.shade600, // Primary action color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Done', // More conclusive text
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Helper widget to build a single macro row
Widget _buildMacroRow(
  BuildContext context,
  String label,
  String value,
  IconData icon,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
          ),
        ),
      ],
    ),
  );
}
