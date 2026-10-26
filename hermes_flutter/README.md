# Hermes Flutter

Flutter replacement app for Hermes public web, authenticated web, iOS, and Android.

## Run Locally

Start the backend from the repo root:

```bash
make up
make api-migrate
```

Run Flutter web:

```bash
flutter run -d chrome --web-port 8080 \
  --dart-define=API_URL=http://localhost:8000 \
  --dart-define=DEV_AUTH_ENABLED=true \
  --dart-define=DEV_AUTH_TOKEN=dev-token
```

## Build

```bash
flutter analyze
flutter test
flutter build web --release
```

## Auth

The app keeps auth behind `AuthRepository`. Local development uses the API's `dev-token` path. Hosted Clerk URLs can be supplied with:

```bash
--dart-define=CLERK_PUBLISHABLE_KEY=...
--dart-define=CLERK_SIGN_IN_URL=...
--dart-define=CLERK_SIGN_UP_URL=...
```

The `clerk_flutter` beta package is intentionally not imported by app code right now because version `0.0.15-beta` is missing generated localization files in the published package. Re-enable it inside `AuthRepository` after the package is fixed or vendored.
