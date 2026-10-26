import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../widgets/app_chrome.dart';

class EnterprisePage extends ConsumerStatefulWidget {
  const EnterprisePage({super.key});

  @override
  ConsumerState<EnterprisePage> createState() => _EnterprisePageState();
}

class _EnterprisePageState extends ConsumerState<EnterprisePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  final _useCase = TextEditingController();
  final _volume = TextEditingController(text: '10,000+ contacts/month');
  bool _saving = false;
  String? _message;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _company.dispose();
    _useCase.dispose();
    _volume.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PublicShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 820;
            return Flex(
              direction: wide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enterprise',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'High-volume plans for teams that need custom limits, onboarding, and support.',
                      ),
                      const SizedBox(height: 20),
                      const Text('Volume tiers beyond standard plans'),
                      const Text('Team workflows and admin controls'),
                      const Text('SLA-backed support'),
                      const Text('Dedicated onboarding'),
                    ],
                  ),
                ),
                if (wide) const SizedBox(width: 28),
                Expanded(child: _form(context)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _company,
                decoration: const InputDecoration(labelText: 'Company'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _volume,
                decoration: const InputDecoration(labelText: 'Desired volume'),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _useCase,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Use case'),
                validator: _required,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: Text(_saving ? 'Sending...' : 'Talk to sales'),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final response =
          await ref.read(hermesRepositoryProvider).createEnterpriseLead(
                name: _name.text,
                email: _email.text,
                company: _company.text,
                useCase: _useCase.text,
                desiredVolume: _volume.text,
              );
      setState(() => _message = response.message);
    } catch (error) {
      setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
