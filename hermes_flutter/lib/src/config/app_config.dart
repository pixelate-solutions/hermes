class AppConfig {
  const AppConfig._();

  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const webOrigin = String.fromEnvironment(
    'WEB_ORIGIN',
    defaultValue: 'https://hermesleads.com',
  );

  static const clerkPublishableKey = String.fromEnvironment(
    'CLERK_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const clerkSignInUrl = String.fromEnvironment(
    'CLERK_SIGN_IN_URL',
    defaultValue: '',
  );

  static const clerkSignUpUrl = String.fromEnvironment(
    'CLERK_SIGN_UP_URL',
    defaultValue: '',
  );

  static const devAuthToken = String.fromEnvironment(
    'DEV_AUTH_TOKEN',
    defaultValue: 'dev-token',
  );

  static const isDevAuthEnabled = bool.fromEnvironment(
    'DEV_AUTH_ENABLED',
    defaultValue: true,
  );
}
