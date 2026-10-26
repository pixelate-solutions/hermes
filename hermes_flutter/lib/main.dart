import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app.dart';

void main() {
  usePathUrlStrategy();
  runApp(const HermesBootstrap());
}

class HermesBootstrap extends StatelessWidget {
  const HermesBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: HermesApp());
  }
}
