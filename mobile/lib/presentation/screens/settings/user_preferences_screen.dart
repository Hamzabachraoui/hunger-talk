import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/user_preferences_service.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({super.key});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  final UserPreferencesService _preferencesService = UserPreferencesService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;

  // Préférences
  List<String> _dietaryRestrictions = [];
  List<String> _allergies = [];
  double? _targetCalories;
  double? _targetProteins;
  double? _targetCarbohydrates;
  double? _targetLipids;

  final List<String> _availableRestrictions = [
    'Végétarien',
    'Végétalien',
    'Vegan',
    'Halal',
    'Cacher',
    'Sans gluten',
    'Sans lactose',
  ];

  final List<String> _availableAllergies = [
    'Arachides',
    'Fruits de mer',
    'Lait',
    'Œufs',
    'Soja',
    'Blé',
    'Noix',
    'Poisson',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await _preferencesService.getPreferences();
      setState(() {
        _dietaryRestrictions = List<String>.from(prefs['dietary_restrictions'] ?? []);
        _allergies = List<String>.from(prefs['allergies'] ?? []);
        _targetCalories = prefs['target_calories']?.toDouble();
        _targetProteins = prefs['target_proteins']?.toDouble();
        _targetCarbohydrates = prefs['target_carbohydrates']?.toDouble();
        _targetLipids = prefs['target_lipids']?.toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _preferencesService.updatePreferences({
        'dietary_restrictions': _dietaryRestrictions,
        'allergies': _allergies,
        'target_calories': _targetCalories,
        'target_proteins': _targetProteins,
        'target_carbohydrates': _targetCarbohydrates,
        'target_lipids': _targetLipids,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Préférences sauvegardées'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Préférences alimentaires'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _savePreferences,
              child: const Text('Enregistrer'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restrictions alimentaires
                    Text(
                      'Restrictions alimentaires',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableRestrictions.map((restriction) {
                        final isSelected = _dietaryRestrictions.contains(restriction);
                        return FilterChip(
                          label: Text(restriction),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _dietaryRestrictions.add(restriction);
                              } else {
                                _dietaryRestrictions.remove(restriction);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Allergies
                    Text(
                      'Allergies',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableAllergies.map((allergy) {
                        final isSelected = _allergies.contains(allergy);
                        return FilterChip(
                          label: Text(allergy),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _allergies.add(allergy);
                              } else {
                                _allergies.remove(allergy);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Objectifs nutritionnels
                    Text(
                      'Objectifs nutritionnels quotidiens',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _targetCalories?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Calories (kcal)',
                        prefixIcon: Icon(Icons.local_fire_department),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _targetCalories = value.isNotEmpty
                            ? double.tryParse(value)
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _targetProteins?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Protéines (g)',
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _targetProteins = value.isNotEmpty
                            ? double.tryParse(value)
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _targetCarbohydrates?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Glucides (g)',
                        prefixIcon: Icon(Icons.energy_savings_leaf),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _targetCarbohydrates = value.isNotEmpty
                            ? double.tryParse(value)
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _targetLipids?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Lipides (g)',
                        prefixIcon: Icon(Icons.water_drop),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _targetLipids = value.isNotEmpty
                            ? double.tryParse(value)
                            : null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _savePreferences,
                        child: const Text('Enregistrer les préférences'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

