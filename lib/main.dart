import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nej/ThemesAndRoutes/AppRoutes.dart';

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
