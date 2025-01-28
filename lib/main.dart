// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:in_app_update/in_app_update.dart';
// Import Home screen or the required page
import 'package:firebase_core/firebase_core.dart';
import 'package:pain_pay/Onboarding/Kyc/VerificationScreen.dart';
import 'package:pain_pay/Onboarding/welcome.dart';
import 'package:pain_pay/services/notification_service.dart';
import 'package:pain_pay/services/update_service.dart';
import 'package:pain_pay/services/update_wrapper.dart';
import 'package:pain_pay/shared/showcase.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:pain_pay/shared/Theme/theme_notifier.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'l10n/';

Future<void> checkForUpdates() async {
  try {
    final updateInfo = await InAppUpdate.checkForUpdate();
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      // Notify the user and start an immediate update
      InAppUpdate.performImmediateUpdate();
    }
  } catch (e) {
    // print('Error checking for updates: $e');
  }
}

Future<void> initializeFirebaseMessaging() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request notification permissions for iOS
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    // print('User granted provisional permission');
  } else {
    // print('User declined or has not accepted permission');
  }

  // Get the FCM token
  String? token = await messaging.getToken();
  // print('FCM Token: $token');
}

// main.dart
// Update your main() function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeFirebaseMessaging();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final showcaseManager = ShowcaseManager();
  await showcaseManager.initializeShowcaseState();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  await dotenv.load();

  runApp(
    // supportedLocales: [
    //   Locale('en'),
    //   Locale('fr'),
    // ],

    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => UpdateService()),
        ChangeNotifierProvider.value(value: notificationService),
        ChangeNotifierProvider.value(value: showcaseManager),
      ],
      child: MyApp(
        notificationService: notificationService,
        navigatorKey: navigatorKey,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.notificationService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _currentLocale = const Locale('en'); // Default locale

  void _changeLocale(Locale newLocale) {
    setState(() {
      _currentLocale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.green[200],
      statusBarIconBrightness: Brightness.light,
    ));

    return UpdateWrapper(
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Ensure overlays and other dependent widgets are built after layout.
          });
          return ShowCaseWidget(
            builder: (context) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'PainPay',
              theme: themeNotifier.lightTheme,
              darkTheme: themeNotifier.darkTheme,
              themeMode: themeNotifier.themeMode,
              navigatorKey: widget.navigatorKey,
              locale: _currentLocale, // Set the current locale
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('fr'), // French
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                // Match locale with supported locales
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first; // Fallback
              },
              home: const Welcome(),
            ),
          );
        },
      ),
    );
  }
}
