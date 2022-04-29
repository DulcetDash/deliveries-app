import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Providers/HomeProvider.dart';

class GetMainStores {
  // Future exec({required BuildContext context}) async {
  //   Uri mainUrl = Uri.parse(
  //       Uri.encodeFull('${context.read<HomeProvider>().bridge}/getStores'));

  //   //Assemble the bundle data
  //   //* @param type: the type of request (past, scheduled, business)
  //   Map<String, String> bundleData = {
  //     'user_fingerprint': context.read<HomeProvider>().user_identifier,
  //   };

  //   try {
  //     http.Response response = await http.post(mainUrl, body: bundleData);

  //     if (response.statusCode == 200) //Got some results
  //     {
  //       log(response.body.toString());
  //     } else //Has some errors
  //     {
  //       log(response.toString());
  //     }
  //   } catch (e) {
  //     log('8');
  //     log(e.toString());
  //   }
  // }
}
