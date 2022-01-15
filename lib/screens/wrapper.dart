import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer/providers/user_related_providers.dart';
import 'package:gamer/screens/app/app.dart';
import 'package:gamer/screens/auth/auth.dart';
import 'package:gamer/screens/loading.dart';

/// Determines whether to show the auth or app screen
/// depending on if the user is signed in or not.
class Wrapper extends ConsumerWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(authStateStreamProvider);

    return userModel.maybeWhen(
      data: (x) => x == null ? const Auth() : const App(),
      orElse: () => const Loading(),
    );
  }
}
