import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/hermes_models.dart';
import '../../providers.dart';
import '../../widgets/app_chrome.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _company = TextEditingController();
  final _role = TextEditingController();
  final _tone = TextEditingController();
  final _sell = TextEditingController();
  bool _hydrated = false;
  String? _message;

  @override
  void dispose() {
    _company.dispose();
    _role.dispose();
    _tone.dispose();
    _sell.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Profile',
      child: FutureBuilder<String?>(
        future: ref.read(authRepositoryProvider).tokenFor(context),
        builder: (context, token) {
          if (!token.hasData) return const CircularProgressIndicator();
          return AsyncPanel<Profile>(
            future: ref.read(hermesRepositoryProvider).profile(token.data),
            builder: (context, profile) {
              if (!_hydrated) {
                _company.text = profile.company ?? '';
                _role.text = profile.role ?? '';
                _tone.text = profile.outreachTone ?? '';
                _sell.text = profile.whatWeSell ?? '';
                _hydrated = true;
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _company,
                        decoration: const InputDecoration(labelText: 'Company'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _role,
                        decoration: const InputDecoration(labelText: 'Role'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _tone,
                        minLines: 3,
                        maxLines: 5,
                        decoration:
                            const InputDecoration(labelText: 'Outreach tone'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _sell,
                        minLines: 3,
                        maxLines: 5,
                        decoration:
                            const InputDecoration(labelText: 'What we sell'),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _save(token.data),
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Save profile'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _acceptTerms(token.data),
                            icon: const Icon(Icons.verified_user_outlined),
                            label: const Text('Accept terms'),
                          ),
                        ],
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 12),
                        Text(_message!),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _save(String? token) async {
    try {
      await ref.read(hermesRepositoryProvider).saveProfile(token, {
        'company': _company.text.trim(),
        'role': _role.text.trim(),
        'outreach_tone': _tone.text.trim(),
        'what_we_sell': _sell.text.trim(),
      });
      setState(() => _message = 'Profile saved.');
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }

  Future<void> _acceptTerms(String? token) async {
    try {
      await ref.read(hermesRepositoryProvider).acceptTerms(token);
      setState(() => _message = 'Terms accepted.');
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }
}
