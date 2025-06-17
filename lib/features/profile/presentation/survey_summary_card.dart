import 'package:flutter/material.dart';
import 'package:biteq/features/profile/entities/profile_user.dart';

class SurveySummaryCard extends StatelessWidget {
  final SurveyResponses surveyResponses;

  const SurveySummaryCard({super.key, required this.surveyResponses});

  Widget _buildInfoColumn(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Current Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoColumn(
                context,
                '${surveyResponses.height.toInt()} cm',
                'Height',
                Icons.height,
              ),
              _buildInfoColumn(
                context,
                '${surveyResponses.age}',
                'Age',
                Icons.cake, // Or Icons.person_outline
              ),
              _buildInfoColumn(
                context,
                surveyResponses.gender,
                'Gender',
                surveyResponses.gender.toLowerCase() == 'male'
                    ? Icons.male
                    : (surveyResponses.gender.toLowerCase() == 'female'
                        ? Icons.female
                        : Icons.person),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.95,
            children: [
              _buildDetailRow(
                context,
                Icons.directions_run,
                'Activity Level',
                surveyResponses.activityLevel,
              ),
              _buildDetailRow(
                context,
                Icons.restaurant,
                'Dietary Pref.',
                surveyResponses.dietaryPreferences,
              ),
              _buildDetailRow(
                context,
                Icons.flag,
                'Goal',
                surveyResponses.goal,
              ),
              _buildDetailRow(
                context,
                Icons.water_drop,
                'Water Intake',
                surveyResponses.glassesOfWater,
              ),
              _buildDetailRow(
                context,
                Icons.fastfood,
                'Meals per Day',
                surveyResponses.mealsPerDay,
              ),
              _buildDetailRow(
                context,
                Icons.sick_outlined,
                'Food Allergies',
                surveyResponses.foodAllergies,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue.shade600, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center, // Center-align the text
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center, // Center-align the text
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
