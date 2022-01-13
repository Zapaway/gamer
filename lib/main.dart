import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamer/screens/app/app.dart';
import 'package:gamer/screens/auth/auth.dart';
import 'package:gamer/screens/loading.dart';
import 'package:gamer/screens/wrapper.dart';

/// For debugging purposes.
/// This was taken from the official Riverpod docs.
/// (https://riverpod.dev/docs/concepts/provider_observer/#usage-)
class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
      ProviderBase provider,
      Object? previousValue,
      Object? newValue,
      ProviderContainer container,
      ) {
    print
('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "newValue": "$newValue"
}
''');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(observers: [   ],child: const GameR()));
}

class GameR extends StatelessWidget {
  const GameR({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      theme: ThemeData(fontFamily: "Montserrat"),
      debugShowCheckedModeBanner: false,

      initialRoute: "/",
      routes: {
        "/": (context) => const Wrapper(),
        "/loading": (context) => const Loading(),
        "/auth": (context) => const Auth(),
        "/app": (context) => const App(),
      }
    );
  }
}
