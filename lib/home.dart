import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gradecryptmobile/genkeys.dart';
import 'package:gradecryptmobile/local_auth_api.dart';
import 'package:gradecryptmobile/main.dart';
import 'package:gradecryptmobile/scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import "package:system_theme/system_theme.dart";

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

String decryptedgrade = "#";

class _HomeState extends State<Home> {
  bool darkMode = SystemTheme.isDarkMode;
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
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: () async {
                      final isAuthenticated = await LocalAuthApi.authenticate(
                          "Bitte Authentifizieren");
                      if (isAuthenticated) {
                        PhoneSwitchPressed();
                      }
                    },
                    icon: const Icon(
                      Icons.upload_file,
                    )),
              ),
              Spacer(),
              Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child:
                          SelectableText(decryptedgrade, textScaleFactor: 13),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Visibility(
                          visible: pointsVisible,
                          child: SelectableText("$reachedp/$maxp",
                              textScaleFactor: 3)),
                    )
                  ],
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

  void PhoneSwitchPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildPopupDialog(context),
    );
  }

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Handy wechseln:'),
      content: Container(
        width: 300,
        height: 320,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: QrImage(
                data: MigrateKeys(),
                version: QrVersions.auto,
                foregroundColor: darkMode == true ? Colors.white : Colors.black,
                size: 270,
              ),
            ),
            Center(
                child: Text("Scanne diesen QR Code mit deinem neuen Handy.")),
          ],
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Schließen'),
        ),
      ],
    );
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

String MigrateKeys() {
  var statement =
      "grmg3212cy1:${int.parse(key_public.toString()).toRadixString(15)}:${int.parse(key_private.toString()).toRadixString(15)}";
  return statement;
}
