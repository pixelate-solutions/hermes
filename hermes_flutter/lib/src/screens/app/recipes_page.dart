import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/hermes_models.dart';
import '../../providers.dart';
import '../../widgets/app_chrome.dart';

class RecipesPage extends ConsumerStatefulWidget {
  const RecipesPage({super.key});

  @override
  ConsumerState<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends ConsumerState<RecipesPage> {
  final _name = TextEditingController(text: 'My recipe');
  final _industry = TextEditingController(text: 'Software');
  final _geo = TextEditingController(text: 'United States');
  final _roles = TextEditingController(text: 'Founder');
  final _max = TextEditingController(text: '25');
  final _notes = TextEditingController();
  int _refresh = 0;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    _industry.dispose();
    _geo.dispose();
    _roles.dispose();
    _max.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Recipes',
      child: FutureBuilder<String?>(
        future: ref.read(authRepositoryProvider).tokenFor(context),
        builder: (context, token) {
          if (!token.hasData) return const CircularProgressIndicator();
          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth > 860;
              return Flex(
                direction: wide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _createCard(token.data)),
                  if (wide) const SizedBox(width: 18) else const SizedBox(height: 18),
                  Expanded(
                    child: AsyncPanel<RecipeList>(
                      key: ValueKey(_refresh),
                      future: ref.read(hermesRepositoryProvider).recipes(token.data),
                      builder: (context, data) {
                        if (data.items.isEmpty) {
                          return const EmptyCard(message: 'No saved recipes yet.');
                        }
                        return Card(
                          child: Column(
                            children: [
                              for (final recipe in data.items)
                                ListTile(
                                  title: Text(recipe.name),
                                  subtitle: Text(recipe.notes ?? 'No notes'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () => _rerun(token.data, recipe),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _createCard(String? token) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Recipe name')),
            const SizedBox(height: 10),
            TextField(controller: _industry, decoration: const InputDecoration(labelText: 'Industry')),
            const SizedBox(height: 10),
            TextField(controller: _geo, decoration: const InputDecoration(labelText: 'Geo')),
            const SizedBox(height: 10),
            TextField(controller: _roles, decoration: const InputDecoration(labelText: 'Roles')),
            const SizedBox(height: 10),
            TextField(
              controller: _max,
              decoration: const InputDecoration(labelText: 'Max contacts'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes'),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _create(token),
                child: const Text('Create recipe'),
              ),
            ),
            if (_message != null) ...[
              const SizedBox(height: 10),
              Text(_message!),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _params() => {
        'industry': _industry.text.trim(),
        'geo': _geo.text.trim(),
        'roles': _roles.text
            .split(',')
            .map((role) => role.trim())
            .where((role) => role.isNotEmpty)
            .toList(),
        'max_contacts': int.tryParse(_max.text) ?? 25,
        'include_verified_email': true,
        'include_phone': false,
        'include_ai': false,
        'enrich': true,
      };

  Future<void> _create(String? token) async {
    try {
      await ref.read(hermesRepositoryProvider).createRecipe(
            token,
            name: _name.text.trim(),
            paramsJson: _params(),
            notes: _notes.text.trim(),
          );
      setState(() {
        _message = 'Recipe created.';
        _refresh++;
      });
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  Future<void> _rerun(String? token, Recipe recipe) async {
    try {
      final jobId = await ref.read(hermesRepositoryProvider).rerunRecipe(token, recipe.id);
      if (mounted) context.go('/app/leads/jobs/$jobId');
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }
}
