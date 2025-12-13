import 'package:flutter/material.dart';
import '../../data/models/recipe_model.dart';
import '../../core/theme/app_colors.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  String _getDifficultyText() {
    if (recipe.difficulty == null) return 'N/A';
    switch (recipe.difficulty!.toLowerCase()) {
      case 'easy':
      case 'facile':
        return 'Facile';
      case 'medium':
      case 'moyen':
        return 'Moyen';
      case 'hard':
      case 'difficile':
        return 'Difficile';
      default:
        return recipe.difficulty!;
    }
  }

  Color _getDifficultyColor() {
    if (recipe.difficulty == null) return AppColors.textSecondary;
    switch (recipe.difficulty!.toLowerCase()) {
      case 'easy':
      case 'facile':
        return AppColors.success;
      case 'medium':
      case 'moyen':
        return AppColors.warning;
      case 'hard':
      case 'difficile':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (recipe.difficulty != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getDifficultyColor(), width: 1),
                      ),
                      child: Text(
                        _getDifficultyText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getDifficultyColor(),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              ),
              if (recipe.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  recipe.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (recipe.calculatedTotalTime > 0)
                    _InfoChip(
                      icon: Icons.access_time,
                      label: '${recipe.calculatedTotalTime} min',
                    ),
                  if (recipe.calculatedTotalTime > 0) const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.restaurant,
                    label: '${recipe.servings} portions',
                  ),
                  if (recipe.nutrition?.calories != null) ...[
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.local_fire_department,
                      label: '${recipe.nutrition!.calories!.toStringAsFixed(0)} kcal',
                    ),
                  ],
                ],
              ),
              if (recipe.isAvailable != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      recipe.isAvailable! ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: recipe.isAvailable!
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      recipe.isAvailable!
                          ? 'Disponible avec votre stock'
                          : 'Ingrédients manquants',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: recipe.isAvailable!
                                ? AppColors.success
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

