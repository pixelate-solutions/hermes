import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/app/billing_page.dart';
import 'screens/app/dashboard_page.dart';
import 'screens/app/job_detail_page.dart';
import 'screens/app/jobs_page.dart';
import 'screens/app/new_job_page.dart';
import 'screens/app/profile_page.dart';
import 'screens/app/recipes_page.dart';
import 'screens/app/results_page.dart';
import 'screens/auth/auth_page.dart';
import 'screens/public/enterprise_page.dart';
import 'screens/public/how_it_works_page.dart';
import 'screens/public/landing_page.dart';
import 'screens/public/pricing_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingPage()),
      GoRoute(path: '/pricing', builder: (context, state) => const PricingPage()),
      GoRoute(
        path: '/how-it-works',
        builder: (context, state) => const HowItWorksPage(),
      ),
      GoRoute(
        path: '/enterprise',
        builder: (context, state) => const EnterprisePage(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const AuthPage(initialMode: AuthMode.signIn),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const AuthPage(initialMode: AuthMode.signUp),
      ),
      GoRoute(
        path: '/app',
        redirect: (context, state) => '/app/dashboard',
      ),
      GoRoute(
        path: '/app/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/app/leads/new',
        builder: (context, state) => const NewJobPage(),
      ),
      GoRoute(
        path: '/app/leads/jobs',
        builder: (context, state) => const JobsPage(),
      ),
      GoRoute(
        path: '/app/leads/jobs/:id',
        builder: (context, state) =>
            JobDetailPage(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/app/leads/results',
        builder: (context, state) => const ResultsPage(),
      ),
      GoRoute(
        path: '/app/recipes',
        builder: (context, state) => const RecipesPage(),
      ),
      GoRoute(
        path: '/app/billing',
        builder: (context, state) => const BillingPage(),
      ),
      GoRoute(
        path: '/app/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
