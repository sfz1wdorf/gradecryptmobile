// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:gradecryptmobile/home.dart';
import 'package:gradecryptmobile/test.dart';
import 'scanner.dart';
import 'genkeys.dart';
import 'cantor.dart';
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
  GenKeys();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

final LocalAuthentication auth = LocalAuthentication();

void GenKeys() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("priv") == false) {
    GetKeys();
    prefs.setInt("public", key_public);
    prefs.setInt("priv", key_private);
    prefs.reload();
    GetPublicKey();
    FlutterNativeSplash.remove();
  } else {
    key_private = prefs.getInt("priv");
    key_public = prefs.getInt("public");
    prefs.reload();
    GetPublicKey();
    FlutterNativeSplash.remove();
  }
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
      home: MyStatefulWidget(),
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
      inv_cantor1(double.parse(key_private.toString())).floor().toString());
  var n = BigInt.parse(
      inv_cantor2(double.parse(key_private.toString())).floor().toString());
  grade = await code.modPow(d, n).toString();
  decryptedgrade = (double.parse(grade) / 100).toString();
  return grade;
}

Future<String> decryptedReached(code) async {
  final prefs = await SharedPreferences.getInstance();
  code = BigInt.parse(code);
  var d = BigInt.parse(
      inv_cantor1(double.parse(key_private.toString())).floor().toString());
  var n = BigInt.parse(
      inv_cantor2(double.parse(key_private.toString())).floor().toString());
  grade = await code.modPow(d, n).toString();
  reachedp = (double.parse(grade) / 100).toString();
  return grade;
}

Future<String> decryptedMax(var code) async {
  final prefs = await SharedPreferences.getInstance();
  code = BigInt.parse(code);
  var d = BigInt.parse(
      inv_cantor1(double.parse(key_private.toString())).floor().toString());
  var n = BigInt.parse(
      inv_cantor2(double.parse(key_private.toString())).floor().toString());
  grade = await code.modPow(d, n).toString();
  maxp = (double.parse(grade) / 100).toString();
  return grade;
}
