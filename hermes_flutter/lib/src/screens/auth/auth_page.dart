import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../widgets/app_chrome.dart';

enum AuthMode { signIn, signUp }

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, required this.initialMode});

  final AuthMode initialMode;

  @override
  Widget build(BuildContext context) {
    return PublicShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _AuthContent(initialMode: initialMode),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthContent extends StatelessWidget {
  const _AuthContent({required this.initialMode});

  final AuthMode initialMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          initialMode == AuthMode.signIn ? 'Sign in' : 'Create account',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(AppConfig.clerkPublishableKey.isEmpty
            ? 'Clerk is not configured locally. Development mode uses the FastAPI dev actor and dev-token.'
            : 'Open the hosted Clerk authentication flow, then return to Hermes.'),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _continue(context),
            icon: const Icon(Icons.login),
            label: Text(AppConfig.clerkPublishableKey.isEmpty
                ? 'Continue in dev mode'
                : 'Continue with Clerk'),
          ),
        ),
      ],
    );
  }

  Future<void> _continue(BuildContext context) async {
    final url = initialMode == AuthMode.signIn
        ? AppConfig.clerkSignInUrl
        : AppConfig.clerkSignUpUrl;
    if (url.isNotEmpty) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return;
    }
    if (context.mounted) context.go('/app/dashboard');
  }
}
