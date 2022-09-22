import 'dart:developer';
import 'dart:io';
import 'package:gradecryptmobile/genkeys.dart';
import 'package:gradecryptmobile/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import "main.dart";
import 'local_auth_api.dart';
import 'dart:convert';

var reachedpoints;
var maxpoints;
void main() => runApp(MaterialApp(
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
    home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('qrView'),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  SwitchedQR() async {
    await controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    // ignore: unrelated_type_equality_checks
                    if (CheckCode(scanned_code.toString()) == true)
                      Text(gctext)
                    else
                      Text(gctext),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Taschenlampe: ${snapshot.data}');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Kamerarichtung: ${describeEnum(snapshot.data!)}');
                                } else {
                                  return const Text('Läd...');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          child: const Text('Pausieren',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () => SwitchedQR(),
                          child: const Text('Fortsetzen',
                              style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 400.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 50,
          borderWidth: 12,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        scanned_code = scanData.code;
      });
    });
  }

  var publskeysw;
  void ShowSwitchDialog(int publskey) {
    publskeysw = publskey;
    MigrationAccepted();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Berechtigung')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

var gctext = "Scanne..";
Future<bool> CheckCode(String code) async {
  final prefs = await SharedPreferences.getInstance();
  final bytes = utf8.encode(getpublkey);
  final base64Str = base64.encode(bytes);
  print(code);

  String pubkey16 = base64Str;
  if (code.toString().contains(("grmg3212cy1"))) {
    code = code.replaceAll("grmg3212cy1:", "");
    gctext = "Authentifiziere...";
    PhoneSwitchRegistered(code);
    return false;
  }
  if(code[0] == "r"){
        code = code.substring(2);
    if (code.toString().contains((pubkey16.toString()))) {
      code = code.replaceAll("${(pubkey16.toString())}:", '');
      var grade = BigInt.parse(code.substring(0, code.indexOf(":")), radix: 16);
      code = code.substring(code.indexOf(":") + 1, code.length);
      reachedpoints =
          BigInt.parse(code.substring(0, code.indexOf(":")), radix: 16);
      code = code.substring(code.indexOf(":"), code.length);
      code = code.substring(code.indexOf(":") + 1, code.length);
      maxpoints = BigInt.parse(code.substring(0, code.indexOf(":")), radix: 16);
            code = code.substring(code.indexOf(":") + 1, code.length);
      CodeID(code);
      CodeFoundPrePoints(grade, reachedpoints, maxpoints);
      gctext = "Code erkannt!";
      return true;
    } else {
      return false;
    }

  }
  if (code[0] == "p") {
    code = code.substring(2);
    if (code.toString().contains((pubkey16.toString()))) {
      code = code.replaceAll("${(pubkey16.toString())}:", '');
      var grade = BigInt.parse(code.substring(0, code.indexOf(":")), radix: 16);
      code = code.substring(code.indexOf(":") + 1, code.length);
      reachedpoints =
          BigInt.parse(code.substring(0, code.indexOf(":")), radix: 16);
      code = code.substring(code.indexOf(":"), code.length);
      code = code.substring(code.indexOf(":") + 1, code.length);
      maxpoints = BigInt.parse(code, radix: 16);
      CodeFoundPrePoints(grade, reachedpoints, maxpoints);
      gctext = "Code erkannt!";
            noCodeID();

      return true;
    } else {
      return false;
    }
  } else {
    if(code[0] == "i"){
      code = code.substring(2);
    if (code.toString().contains((pubkey16.toString()))) {
      code = code.replaceAll("${(pubkey16.toString())}:", '');
      var code16 = code.substring(0, code.indexOf(":"));
                  code = code.substring(code.indexOf(":") + 1, code.length);

      CodeID(code); 
      CodeFoundPre(BigInt.parse(code16, radix: 16).toString());
      gctext = "Code erkannt!";
      return true;
    } else {
      gctext = "Code invalide!";
      return false;
    }
    }else{

    

    code = code.substring(2);
    if (code.toString().contains((pubkey16.toString()))) {
      code = code.replaceAll("${(pubkey16.toString())}:", '');
      var code16 = (BigInt.parse(code, radix: 16)).toString();
      code = code16;
      CodeFoundPre(code);
      gctext = "Code erkannt!";
            noCodeID();

      return true;
    } else {
      gctext = "Code invalide!";
      return false;
    }
  }
  }
}



var private_10;
var public_10;
void PhoneSwitchRegistered(String code) async {
  final isAuthenticated = await LocalAuthApi.authenticate(
      "Sie sind dabei, einen Key auf Ihr Gerät zu migrieren. Authentifizierung zur Bestätigung:");
  if (isAuthenticated) {
    String decoded = utf8.decode(base64.decode(code));
    public_10 = decoded.substring(0, decoded.indexOf("'"));
    private_10 = decoded.substring(decoded.indexOf("'") + 1, code.length);
    scanned_code = null;
    _QRViewExampleState().ShowSwitchDialog(public_10);
  }
}

void CodeFoundPre(code) {
  MyApp().CodeFound(code);
}

void CodeFoundPrePoints(grade, reachedpoints, maxpoints) {
  MyApp().CodeFoundPoints(grade, reachedpoints, maxpoints);
}

void MigrationAccepted() {
  key_private = private_10;
  key_public = public_10;
  ReplaceKeys();
}

void ReplaceKeys() async {
  final prefs = await SharedPreferences.getInstance();
  getpublkey = public_10;
  prefs.setInt("public", public_10);
  prefs.setInt("priv", private_10);
  prefs.reload();
}

void SwitchedToQR() {
  _QRViewExampleState().SwitchedQR();
}
