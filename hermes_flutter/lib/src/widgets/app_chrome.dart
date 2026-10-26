import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers.dart';

class PublicShell extends StatelessWidget {
  const PublicShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PublicNav(),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PublicNav extends StatelessWidget {
  const PublicNav({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/'),
            child: const Text(
              'Hermes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          const Spacer(),
          if (!compact) ...[
            TextButton(
              onPressed: () => context.go('/how-it-works'),
              child: const Text('How it works'),
            ),
            TextButton(
              onPressed: () => context.go('/pricing'),
              child: const Text('Pricing'),
            ),
            TextButton(
              onPressed: () => context.go('/enterprise'),
              child: const Text('Enterprise'),
            ),
          ],
          TextButton(
            onPressed: () => context.go('/sign-in'),
            child: const Text('Sign in'),
          ),
          FilledButton(
            onPressed: () => context.go('/sign-up'),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = _selectedDestination(GoRouterState.of(context).uri.path);
    final isWide = MediaQuery.sizeOf(context).width >= 920;

    final body = SafeArea(
      child: Row(
        children: [
          if (isWide)
            NavigationRail(
              extended: MediaQuery.sizeOf(context).width >= 1180,
              selectedIndex: destination,
              onDestinationSelected: (index) => context.go(_appLinks[index].path),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Hermes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              destinations: [
                for (final link in _appLinks)
                  NavigationRailDestination(
                    icon: Icon(link.icon),
                    label: Text(link.label),
                  ),
              ],
            ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(title),
                  actions: [
                    TextButton.icon(
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut(context);
                        if (context.mounted) context.go('/');
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign out'),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: body,
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: destination.clamp(0, 4),
              onDestinationSelected: (index) =>
                  context.go(_appLinks[index].path),
              destinations: [
                for (final link in _appLinks.take(5))
                  NavigationDestination(
                    icon: Icon(link.icon),
                    label: link.label,
                  ),
              ],
            ),
    );
  }
}

class AsyncPanel<T> extends StatelessWidget {
  const AsyncPanel({
    super.key,
    required this.future,
    required this.builder,
    this.emptyMessage,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return ErrorCard(message: snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return EmptyCard(message: emptyMessage ?? 'Nothing to show yet.');
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

class EmptyCard extends StatelessWidget {
  const EmptyCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int _selectedDestination(String path) {
  final index = _appLinks.indexWhere((link) => path.startsWith(link.path));
  return index < 0 ? 0 : index;
}

class _AppLink {
  const _AppLink(this.path, this.label, this.icon);

  final String path;
  final String label;
  final IconData icon;
}

const _appLinks = [
  _AppLink('/app/dashboard', 'Dashboard', Icons.dashboard_outlined),
  _AppLink('/app/leads/new', 'New', Icons.add_circle_outline),
  _AppLink('/app/leads/jobs', 'Jobs', Icons.work_outline),
  _AppLink('/app/leads/results', 'Results', Icons.table_chart_outlined),
  _AppLink('/app/recipes', 'Recipes', Icons.bookmark_border),
  _AppLink('/app/billing', 'Billing', Icons.credit_card),
  _AppLink('/app/profile', 'Profile', Icons.person_outline),
];
