import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';
import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';

// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

  // This ensures you don't initialize Firebase multiple times
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY']!,
          appId: dotenv.env['FIREBASE_APP_ID']!,
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
          projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
          authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'],
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'],
          measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
        ),
      );
    }
  } catch (e) {
    print('⚠️ Firebase already initialized: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}



class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BiteQ - Smart Food Diet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        textTheme: Theme.of(context).textTheme, // default system font
        useMaterial3: true,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class NavigateButton extends StatelessWidget {
  final String route;
  final String text;

  const NavigateButton({required this.route, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go(route);
      },
      child: Text(text),
    );
  }
}
