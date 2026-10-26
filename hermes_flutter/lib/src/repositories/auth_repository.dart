import 'package:flutter/widgets.dart';

import '../config/app_config.dart';

class AuthRepository {
  Future<String?> tokenFor(BuildContext context) async {
    if (AppConfig.isDevAuthEnabled) {
      return AppConfig.devAuthToken;
    }
    return null;
  }

  bool isSignedIn(BuildContext context) {
    return AppConfig.isDevAuthEnabled;
  }

  Future<void> signOut(BuildContext context) async {
    return;
  }
}
