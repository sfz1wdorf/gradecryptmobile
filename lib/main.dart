// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:gradecryptmobile/home.dart';
import 'package:vibration/vibration.dart';
import 'scanner.dart';
import 'genkeys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import "package:local_auth/local_auth.dart";

var reachedp = "#";
var maxp = "#";
var scanned_code;
var pointsVisible = false;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GetStoredList();
  GenKeys();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
  initState();
}
void upadteStoredList() async{
    final prefs = await SharedPreferences.getInstance();
      prefs.setStringList("codeIDs", codeIDs);
      prefs.setStringList("storedGrades", storedGrades);
}
List<String> storedGrades = [];
List<String> codeIDs = [];

void GetStoredList() async{
    final prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("storedGrades") && prefs.containsKey("codeIDs")){
      codeIDs = prefs.getStringList("codeIDs")!;
      storedGrades = prefs.getStringList("storedGrades")!;

    }
}

final LocalAuthentication auth = LocalAuthentication();

void GenKeys() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("priv") == false) {
    GetKeys();
    prefs.setString("public", key_public.toString());
    prefs.setString("priv", key_private.toString());
    prefs.setString("public_show", key_public_show.toString());
    prefs.reload();
    GetPublicKey();
    FlutterNativeSplash.remove();
  } else {
    key_private = prefs.getString("priv");
    key_public = prefs.getString("public");
    prefs.reload();
    GetPublicKey();
    FlutterNativeSplash.remove();
  }
}

@override
initState() {
  // update _controller with value whenever _myString changes
  decryptNotifier.addListener(Vibrate);
}

void Vibrate() async {
  try {
    Vibration.vibrate();
  } catch (e) {}
}

var grade;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  void CodeFound(correctCode) {
    String scanned_code = correctCode;
    grade = decrypted(correctCode);
    pointsVisible = false;
  }

  void CodeFoundPoints(var correctCode, var reachedpoints, var maxpoints) {
    String scanned_code = correctCode.toString();
    decryptedReached(reachedpoints.toString());

    decryptedMax(maxpoints.toString());

    decrypted(correctCode.toString());

    pointsVisible = true;
  }

  static const String _title = 'Gradecrypt';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gradecryt',
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
      home: const MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    QRViewExample(),
    const Home(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        SwitchedToQR();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gradecrypt'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'QR',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

Future<String> decrypted(code) async {
  final prefs = await SharedPreferences.getInstance();
  code = BigInt.parse(code);
  var d = BigInt.parse(
      key_private.toString().substring(0, key_private.toString().indexOf("'")));
  var n = BigInt.parse(key_private.toString().substring(
      key_private.toString().indexOf("'") + 1, key_private.toString().length));
  grade = await code.modPow(d, n).toString();
  var decryptedgradei = (double.parse(grade) / 100);
  if (decryptedgradei / decryptedgradei.round() == 1) {
    decryptedgrade = (double.parse(grade) / 100).toInt().toString();
    decryptNotifier.value = decryptedgrade;
  } else {
    decryptedgrade = (double.parse(grade) / 100).toString();
    decryptNotifier.value = decryptedgrade;
  }
  return grade;
}

Future<String> decryptedReached(code) async {
  final prefs = await SharedPreferences.getInstance();
  code = BigInt.parse(code);
  var d = BigInt.parse(
      key_private.toString().substring(0, key_private.toString().indexOf("'")));
  var n = BigInt.parse(key_private.toString().substring(
      key_private.toString().indexOf("'") + 1, key_private.toString().length));
  grade = await code.modPow(d, n).toString();
  var reachedpi = double.parse(grade) / 100;
  if (reachedpi / reachedpi.round() == 1) {
    reachedp = (double.parse(grade) / 100).toInt().toString();
  } else {
    reachedp = (double.parse(grade) / 100).toString();
  }
  return grade;
}

Future<String> decryptedMax(var code) async {
  final prefs = await SharedPreferences.getInstance();
  code = BigInt.parse(code);
  var d = BigInt.parse(
      key_private.toString().substring(0, key_private.toString().indexOf("'")));
  var n = BigInt.parse(key_private.toString().substring(
      key_private.toString().indexOf("'") + 1, key_private.toString().length));
  grade = await code.modPow(d, n).toString();
  var maxpi = double.parse(grade) / 100;
  if (maxpi / maxpi.round() == 1) {
    maxp = (double.parse(grade) / 100).toInt().toString();
  } else {
    maxp = (double.parse(grade) / 100).toString();
  }
  return grade;
}
void CodeID(String code) {
  useCodeID = true;
  codeID = code;
}
void noCodeID(){
  useCodeID = false;
}
var useCodeID = false;
var codeID = "";