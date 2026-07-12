import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';
import 'services/push_notification_service.dart';
import 'services/cart_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  await Supabase.initialize(
    url: dotenv.env['supabaseUrl']!,
    anonKey: dotenv.env['supabaseAnonKey']!,
  );

  await CartService.instance.loadCart();

  runApp(const SmartLedApp());
}

class SmartLedApp extends StatefulWidget {
  const SmartLedApp({super.key});

  @override
  State<SmartLedApp> createState() => _SmartLedAppState();
}

class _SmartLedAppState extends State<SmartLedApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if ((event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) && session != null) {
        if (!kIsWeb) {
          PushNotificationService.instance.initialize();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Project Builder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundColor,
        primaryColor: AppColors.primaryColor,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.mainTextColor),
          bodyLarge: TextStyle(color: AppColors.mainTextColor),
        ),
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryColor,
          surface: AppColors.surfaceColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceColor,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.secondaryTextColor,
        ),
      ),
      home: Supabase.instance.client.auth.currentSession == null
          ? const LoginScreen()
          : const MainNavigation(),
    );
  }
}