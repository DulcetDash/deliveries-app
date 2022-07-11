import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orniss/ThemesAndRoutes/AppRoutes.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'components/Providers/HomeProvider.dart';
import 'components/Providers/RegistrationProvider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomeProvider()),
      ChangeNotifierProvider(create: (_) => RegistrationProvider())
    ],
    child: const AppGeneralEntry(),
  ));
}
