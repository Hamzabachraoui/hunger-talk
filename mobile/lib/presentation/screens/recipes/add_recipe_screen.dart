import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/recipe_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/recipe_parser_service.dart';

class AddRecipeScreen extends StatefulWidget {
  final String? suggestion;
  
  const AddRecipeScreen({super.key, this.suggestion});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController(text: '4');
  
  String? _difficulty;
  bool _isSaving = false;
  
  final List<Map<String, dynamic>> _ingredients = [];
  final List<Map<String, dynamic>> _steps = [];
  
  static const List<String> _difficulties = ['Facile', 'Moyen', 'Difficile'];
  static const List<String> _units = ['g', 'kg', 'ml', 'L', 'pièce', 'unité', 'boîte', 'paquet', 'bouteille', 'sachet', 'tasse', 'cuillère à soupe'];

  @override
  void initState() {
    super.initState();
    // Si une suggestion est fournie, parser et remplir les champs automatiquement
    if (widget.suggestion != null && widget.suggestion!.isNotEmpty) {
      _parseAndFillRecipe(widget.suggestion!);
    }
  }

  void _parseAndFillRecipe(String suggestion) {
    final parser = RecipeParserService();
    final parsed = parser.parseRecipeFromText(suggestion);
    
    setState(() {
      if (parsed.name != null && parsed.name!.isNotEmpty) {
        _nameController.text = parsed.name!;
      }
      
      if (parsed.description != null && parsed.description!.isNotEmpty) {
        _descriptionController.text = parsed.description!;
      }
      
      if (parsed.prepTime != null) {
        _prepTimeController.text = parsed.prepTime.toString();
      }
      
      if (parsed.cookingTime != null) {
        _cookingTimeController.text = parsed.cookingTime.toString();
      }
      
      if (parsed.difficulty != null) {
        _difficulty = parsed.difficulty;
      }
      
      if (parsed.servings != null) {
        _servingsController.text = parsed.servings.toString();
      }
      
      // Ajouter les ingrédients parsés
      _ingredients.clear();
      _ingredients.addAll(parsed.ingredients);
      
      // Ajouter les étapes parsées
      _steps.clear();
      _steps.addAll(parsed.steps);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins un ingrédient')),
      );
      return;
    }
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une étape')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prepTime = _prepTimeController.text.isNotEmpty 
          ? int.tryParse(_prepTimeController.text) 
          : null;
      final cookingTime = _cookingTimeController.text.isNotEmpty 
          ? int.tryParse(_cookingTimeController.text) 
          : null;
      final totalTime = (prepTime ?? 0) + (cookingTime ?? 0);
      final servings = int.tryParse(_servingsController.text) ?? 4;

      final recipeData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        'preparation_time': prepTime,
        'cooking_time': cookingTime,
        'total_time': totalTime > 0 ? totalTime : null,
        'difficulty': _difficulty,
        'servings': servings,
        'ingredients': _ingredients.map((ing) => {
          'ingredient_name': ing['name'],
          'quantity': ing['quantity'],
          'unit': ing['unit'],
          'optional': ing['optional'] ?? false,
        }).toList(),
        'steps': _steps.map((step) => {
          'step_number': step['number'],
          'instruction': step['instruction'],
        }).toList(),
      };

      final recipeProvider = context.read<RecipeProvider>();
      final success = await recipeProvider.createRecipe(recipeData);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recette créée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recipeProvider.error ?? 'Erreur lors de la création'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _addIngredient() {
    showDialog(
      context: context,
      builder: (context) => _AddIngredientDialog(
        onAdd: (ingredient) {
          setState(() {
            _ingredients.add(ingredient);
          });
        },
        units: _units,
      ),
    );
  }

  void _editIngredient(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddIngredientDialog(
        ingredient: _ingredients[index],
        onAdd: (ingredient) {
          setState(() {
            _ingredients[index] = ingredient;
          });
        },
        units: _units,
      ),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    showDialog(
      context: context,
      builder: (context) => _AddStepDialog(
        stepNumber: _steps.length + 1,
        onAdd: (step) {
          setState(() {
            _steps.add(step);
          });
        },
      ),
    );
  }

  void _editStep(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddStepDialog(
        step: _steps[index],
        stepNumber: index + 1,
        onAdd: (step) {
          setState(() {
            _steps[index] = step;
          });
        },
      ),
    );
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
      // Réorganiser les numéros
      for (int i = index; i < _steps.length; i++) {
        _steps[i]['number'] = i + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/recipes');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.suggestion != null ? 'Créer une recette depuis la suggestion' : 'Nouvelle recette'),
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
                onPressed: _save,
                child: const Text('Enregistrer'),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.suggestion != null) ...[
                  Card(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Suggestion de l\'IA',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_ingredients.isNotEmpty || _steps.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                if (_ingredients.isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_ingredients.length} ingrédient(s)',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_steps.isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_steps.length} étape(s)',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la recette *',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                    hintText: 'La suggestion de l\'IA est pré-remplie ci-dessus',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prepTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Préparation (min)',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _cookingTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Cuisson (min)',
                          prefixIcon: Icon(Icons.timer),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _difficulty,
                        decoration: const InputDecoration(
                          labelText: 'Difficulté',
                          prefixIcon: Icon(Icons.bar_chart),
                        ),
                        items: _difficulties.map((d) {
                          return DropdownMenuItem<String>(
                            value: d,
                            child: Text(d),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _difficulty = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        decoration: const InputDecoration(
                          labelText: 'Portions *',
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requis';
                          }
                          final servings = int.tryParse(value);
                          if (servings == null || servings < 1) {
                            return 'Min: 1';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ingrédients',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                if (_ingredients.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucun ingrédient ajouté'),
                    ),
                  )
                else
                  ..._ingredients.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ingredient = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${ingredient['name']} - ${ingredient['quantity']} ${ingredient['unit']}'),
                        subtitle: ingredient['optional'] == true ? const Text('Optionnel') : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editIngredient(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeIngredient(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Étapes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      onPressed: _addStep,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter'),
                    ),
                  ],
                ),
                if (_steps.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucune étape ajoutée'),
                    ),
                  )
                else
                  ..._steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${step['number']}'),
                        ),
                        title: Text(step['instruction']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editStep(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeStep(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddIngredientDialog extends StatefulWidget {
  final Map<String, dynamic>? ingredient;
  final Function(Map<String, dynamic>) onAdd;
  final List<String> units;

  const _AddIngredientDialog({
    this.ingredient,
    required this.onAdd,
    required this.units,
  });

  @override
  State<_AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<_AddIngredientDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedUnit = 'g';
  bool _optional = false;

  @override
  void initState() {
    super.initState();
    if (widget.ingredient != null) {
      _nameController.text = widget.ingredient!['name'] ?? '';
      _quantityController.text = widget.ingredient!['quantity'].toString();
      _selectedUnit = widget.ingredient!['unit'] ?? 'g';
      _optional = widget.ingredient!['optional'] ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nom')),
      );
      return;
    }
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une quantité valide')),
      );
      return;
    }
    widget.onAdd({
      'name': _nameController.text.trim(),
      'quantity': quantity,
      'unit': _selectedUnit,
      'optional': _optional,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ingredient == null ? 'Ajouter un ingrédient' : 'Modifier l\'ingrédient'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                prefixIcon: Icon(Icons.shopping_bag),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantité *',
                      prefixIcon: Icon(Icons.scale),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unité',
                    ),
                    items: widget.units.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Optionnel'),
              value: _optional,
              onChanged: (value) {
                setState(() {
                  _optional = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

class _AddStepDialog extends StatefulWidget {
  final Map<String, dynamic>? step;
  final int stepNumber;
  final Function(Map<String, dynamic>) onAdd;

  const _AddStepDialog({
    this.step,
    required this.stepNumber,
    required this.onAdd,
  });

  @override
  State<_AddStepDialog> createState() => _AddStepDialogState();
}

class _AddStepDialogState extends State<_AddStepDialog> {
  final _instructionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.step != null) {
      _instructionController.text = widget.step!['instruction'] ?? '';
    }
  }

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_instructionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une instruction')),
      );
      return;
    }
    widget.onAdd({
      'number': widget.step?['number'] ?? widget.stepNumber,
      'instruction': _instructionController.text.trim(),
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Étape ${widget.stepNumber}'),
      content: TextField(
        controller: _instructionController,
        decoration: const InputDecoration(
          labelText: 'Instruction *',
          prefixIcon: Icon(Icons.list),
        ),
        maxLines: 5,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

