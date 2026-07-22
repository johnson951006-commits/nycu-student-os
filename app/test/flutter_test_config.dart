import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(Future<void> Function() testMain) {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(),
    run: testMain,
  );
}