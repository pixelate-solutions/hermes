import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'repositories/auth_repository.dart';
import 'repositories/hermes_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final hermesRepositoryProvider = Provider<HermesRepository>(
  (ref) => HermesRepository(ref.watch(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
