import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NutritionCard extends StatelessWidget {
  final String label;
  final double value;
  final double? target;
  final String unit;
  final IconData icon;
  final Color color;

  const NutritionCard({
    super.key,
    required this.label,
    required this.value,
    this.target,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = target != null && target! > 0 ? (value / target! * 100).clamp(0, 100) : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${value.toStringAsFixed(0)} $unit',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (target != null && target! > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage! / 100,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Objectif: ${target!.toStringAsFixed(0)} $unit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

