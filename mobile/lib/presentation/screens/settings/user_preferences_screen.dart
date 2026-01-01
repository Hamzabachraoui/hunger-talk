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
  
  // Controllers pour les champs texte
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinsController = TextEditingController();
  final TextEditingController _carbohydratesController = TextEditingController();
  final TextEditingController _lipidsController = TextEditingController();
  final TextEditingController _customRestrictionController = TextEditingController();
  final TextEditingController _customAllergyController = TextEditingController();

  final List<String> _availableRestrictions = [
    'Végétarien',
    'Végétalien',
    'Vegan',
    'Halal',
    'Cacher',
    'Sans gluten',
    'Sans lactose',
    'Pescétarien',
    'Flexitarien',
    'Paleo',
    'Cétogène',
    'Sans sucre',
    'Sans sel',
    'Faible en glucides',
    'Riche en protéines',
    'Crudivore',
    'Frugivore',
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
    'Crustacés',
    'Mollusques',
    'Sésame',
    'Moutarde',
    'Céleri',
    'Lupin',
    'Sulfites',
    'Amandes',
    'Noisettes',
    'Noix de cajou',
    'Pistaches',
    'Noix de pécan',
    'Noix de macadamia',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  double? _parseNumber(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    // Pour Decimal ou autres types numériques
    try {
      return double.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await _preferencesService.getPreferences();
      
      // Parser les valeurs numériques
      final calories = _parseNumber(prefs['daily_calorie_goal'] ?? prefs['target_calories']);
      final proteins = _parseNumber(prefs['daily_protein_goal'] ?? prefs['target_proteins']);
      final carbs = _parseNumber(prefs['daily_carb_goal'] ?? prefs['target_carbohydrates']);
      final lipids = _parseNumber(prefs['daily_fat_goal'] ?? prefs['target_lipids']);
      
      setState(() {
        _dietaryRestrictions = List<String>.from(prefs['dietary_restrictions'] ?? []);
        _allergies = List<String>.from(prefs['allergies'] ?? []);
        _targetCalories = calories;
        _targetProteins = proteins;
        _targetCarbohydrates = carbs;
        _targetLipids = lipids;
        _isLoading = false;
      });
      
      // Mettre à jour les controllers après avoir mis à jour l'état
      _caloriesController.text = _targetCalories?.toString() ?? '';
      _proteinsController.text = _targetProteins?.toString() ?? '';
      _carbohydratesController.text = _targetCarbohydrates?.toString() ?? '';
      _lipidsController.text = _targetLipids?.toString() ?? '';
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _addCustomRestriction() {
    final text = _customRestrictionController.text.trim();
    if (text.isNotEmpty && !_dietaryRestrictions.contains(text)) {
      setState(() {
        _dietaryRestrictions.add(text);
        _customRestrictionController.clear();
      });
    }
  }

  void _addCustomAllergy() {
    final text = _customAllergyController.text.trim();
    if (text.isNotEmpty && !_allergies.contains(text)) {
      setState(() {
        _allergies.add(text);
        _customAllergyController.clear();
      });
    }
  }

  void _removeRestriction(String restriction) {
    setState(() {
      _dietaryRestrictions.remove(restriction);
    });
  }

  void _removeAllergy(String allergy) {
    setState(() {
      _allergies.remove(allergy);
    });
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbohydratesController.dispose();
    _lipidsController.dispose();
    _customRestrictionController.dispose();
    _customAllergyController.dispose();
    super.dispose();
  }

  Future<void> _savePreferences() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _preferencesService.updatePreferences({
        'dietary_restrictions': _dietaryRestrictions,
        'allergies': _allergies,
        'daily_calorie_goal': _targetCalories,
        'daily_protein_goal': _targetProteins,
        'daily_carb_goal': _targetCarbohydrates,
        'daily_fat_goal': _targetLipids,
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Retourner en arrière avec Navigator (car ouvert via Navigator.push)
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
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
                    const SizedBox(height: 16),
                    // Valeurs personnalisées pour restrictions
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customRestrictionController,
                            decoration: InputDecoration(
                              labelText: 'Ajouter une restriction personnalisée',
                              hintText: 'Ex: Sans arachides',
                              prefixIcon: const Icon(Icons.add_circle_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: (_) => _addCustomRestriction(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addCustomRestriction,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                    // Afficher les restrictions personnalisées (celles qui ne sont pas dans la liste)
                    if (_dietaryRestrictions.any((r) => !_availableRestrictions.contains(r)))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _dietaryRestrictions
                              .where((r) => !_availableRestrictions.contains(r))
                              .map((restriction) {
                            return Chip(
                              label: Text(restriction),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeRestriction(restriction),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                            );
                          }).toList(),
                        ),
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
                    const SizedBox(height: 16),
                    // Valeurs personnalisées pour allergies
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customAllergyController,
                            decoration: InputDecoration(
                              labelText: 'Ajouter une allergie personnalisée',
                              hintText: 'Ex: Fraises',
                              prefixIcon: const Icon(Icons.add_circle_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onSubmitted: (_) => _addCustomAllergy(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addCustomAllergy,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                    // Afficher les allergies personnalisées (celles qui ne sont pas dans la liste)
                    if (_allergies.any((a) => !_availableAllergies.contains(a)))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _allergies
                              .where((a) => !_availableAllergies.contains(a))
                              .map((allergy) {
                            return Chip(
                              label: Text(allergy),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeAllergy(allergy),
                              backgroundColor: Colors.red.withOpacity(0.1),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Objectifs nutritionnels
                    Text(
                      'Objectifs nutritionnels quotidiens',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _caloriesController,
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
                      controller: _proteinsController,
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
                      controller: _carbohydratesController,
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
                      controller: _lipidsController,
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
      ),
    );
  }
}

