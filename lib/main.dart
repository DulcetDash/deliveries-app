import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dulcetdash/ThemesAndRoutes/AppRoutes.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'components/Providers/HomeProvider.dart';
import 'components/Providers/RegistrationProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught errors from the framework to Crashlytics.
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Stripe.publishableKey =
  //     'pk_test_51O0XLUAUT5H40gaH5WWvNlm8C5zeGtDuP21HAovvUoYD0iiwLPsEI6MsqvH0TaUBD1GGLUe1dbrJFLd7AAfXyBgu00o63h1Xef';

  Stripe.publishableKey =
      'pk_live_51O0XLUAUT5H40gaHyHou21pQxwqdfrj9qQA4Z5aHUGqE62JSLRv43NHcidazu1rJxQoFRqANn1pNuqwX6kE8a4Yp006DeFT3Dh';

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomeProvider()),
      ChangeNotifierProvider(create: (_) => RegistrationProvider())
    ],
    child: EasyLocalization(
        supportedLocales: [Locale('en'), Locale('fr')],
        path:
            'assets/translations', // <-- change the path of the translation files
        fallbackLocale: Locale('en'),
        useFallbackTranslations: true,
        saveLocale: true,
        child: WillPopScope(
          onWillPop: () async => Future.value(false),
          child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: const AppGeneralEntry()),
        )),
  ));
}
