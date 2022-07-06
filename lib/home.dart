import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gradecryptmobile/genkeys.dart';
import 'package:gradecryptmobile/main.dart';
import 'package:gradecryptmobile/scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

String decryptedgrade = "#";

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gradecrypt',
        theme: ThemeData(
          brightness: Brightness.light,
          /* light theme settings */
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          /* dark theme settings */
        ),
        themeMode: ThemeMode.system,
        /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Column(
            children: [
              Spacer(),
              Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.center,
                  child: SelectableText(decryptedgrade, textScaleFactor: 9),
                ),
              ),
              Spacer(),
              Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Center(
                      child: SelectableText("Key: ${getpublkey.toString()}")),
                ),
              ),
            ],
          ),
        ));
  }
}

var getpublkey;
void GetPublicKey() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.reload();
  while (prefs.getInt("public") == null) {
    getpublkey = int.parse(prefs.getInt("public").toString());
  }
  getpublkey = int.parse(prefs.getInt("public").toString());
}
