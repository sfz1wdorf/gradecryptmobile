import 'package:flutter/material.dart';
import 'package:gradecryptmobile/genkeys.dart';
import 'package:gradecryptmobile/local_auth_api.dart';
import 'package:gradecryptmobile/main.dart';
import 'package:gradecryptmobile/stored_grades.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import "package:system_theme/system_theme.dart";
import "dart:convert";

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

ValueNotifier<String> decryptNotifier = ValueNotifier<String>("");

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
                child: Row(
                  children: [
                    Spacer(),
                    Visibility(
                      visible: storedGrades.isNotEmpty,
                      child: IconButton(onPressed: (() async{
                        final isAuthenticated = await LocalAuthApi.authenticate(
                                "Bitte Authentifizieren");
                            if (isAuthenticated) {
                              GetStoredList();
                                Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GradeWindow()),
                      );;
                            }
                    
                      }), icon: Icon(Icons.list_alt)),
                    ),
                    IconButton(
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
                  ],
                ),
              ),
              Spacer(),
              Container(
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Visibility(visible: useCodeID, child: SelectableText(codeID)),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SelectableText(decryptedgrade,
                          textScaleFactor: 11.25),
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
                      child: SelectableText(
                    "Key:\n $getpublkey",
                    textAlign: TextAlign.center,
                  )),
                ),
              ),
            ],
          ),
          
  floatingActionButton: Padding(
    padding: const EdgeInsets.all(22.0),
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 40,
        width: 40,
        child: Visibility(
          visible: useCodeID,
          child: FloatingActionButton(
            onPressed: () {
              if(codeIDs.contains(codeID) == false){
              codeIDs.add(codeID);
              storedGrades.add("$codeID;$decryptedgrade;$reachedp;$maxp");
              upadteStoredList();
              }
            },
            backgroundColor: Color.fromARGB(255, 127, 127, 127),
            child: Icon(Icons.add),
          ),
        ),
      ),
    ),
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
        Column(
          children: [
            new TextButton(
              onPressed: () {
                NewKeyPressed();
                Navigator.of(context).pop();
              },
              child: const Text('Keys neu Generieren'),
            ),
            new TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Schließen'),
            ),
          ],
        ),
      ],
    );
  }

  void NewKeyPressed() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("public");
    prefs.remove("priv");
    prefs.reload();
    GenKeys();
    GetPublicKey();
    setState(() {
      _HomeState();
    });
  }
}

var getpublkey;
void GetPublicKey() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.reload();
  while (prefs.getString("public") == null) {
    getpublkey = prefs.getString("public_show");
  }
  getpublkey = prefs.getString("public_show");
}

//you know karsten, you know what is los with karsten?
String MigrateKeys() {
  var karsten = "${key_public.toString()}:${key_private.toString()}";
  final bytes = utf8.encode(karsten);
  final ended = base64.encode(bytes);
  var statement = "grmg3212cy1:$ended";
  return statement;
}
