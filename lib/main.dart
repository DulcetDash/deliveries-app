import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orniss/ThemesAndRoutes/AppRoutes.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'components/Providers/HomeProvider.dart';
import 'components/Providers/RegistrationProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomeProvider()),
      ChangeNotifierProvider(create: (_) => RegistrationProvider())
    ],
    child: const AppGeneralEntry(),
  ));
}
