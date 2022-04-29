// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:nej/components/Home.dart';
import 'package:provider/src/provider.dart';
import 'package:nej/ThemesAndRoutes/AppTheme.dart' as AppTheme;

import '../Components/Providers/RegistrationProvider.dart';

class AppGeneralEntry extends StatefulWidget {
  const AppGeneralEntry({Key? key}) : super(key: key);

  @override
  _AppGeneralEntryState createState() => _AppGeneralEntryState();
}

class _AppGeneralEntryState extends State<AppGeneralEntry> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: AppTheme.appTheme, initialRoute: '/', routes: {
      '/': (context) => const Home(),
    });
  }
}
