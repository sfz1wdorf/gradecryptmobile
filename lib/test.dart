import 'dart:math';

import 'package:gradecryptmobile/cantor.dart';
import 'package:gradecryptmobile/main.dart';

var correct_grade;
Future<String> decrypted(code, int key_private) async {
  code = BigInt.parse(code);
  var d = BigInt.parse(
      inv_cantor1(double.parse(key_private.toString())).floor().toString());
  var n = BigInt.parse(
      inv_cantor2(double.parse(key_private.toString())).floor().toString());
  grade = code.modPow(d, n).toString();
  correct_grade = grade;
  return grade;
}

bool testSuccess(int PublicKey, int PrivateKey) {
  Random random = new Random();
  int grade = random.nextInt(7) * 100;
  while (grade == 0) {
    int grade = random.nextInt(7) * 100;
  }
  var e = inv_cantor1(PublicKey);
  var n = inv_cantor2(PublicKey);
  var encrypted = rsa(grade.toString(), e, n);
  decrypted(encrypted, PrivateKey);
  if (int.parse(correct_grade) == grade) {
    return true;
  } else {
    return false;
  }
}

String rsa(String grade, double e, double n) {
  var gradeDouble = double.parse(grade);
  var gradeInt = int.parse((gradeDouble).round().toString());
  BigInt gradeBig = BigInt.parse(gradeInt.toString());
  BigInt eBig = BigInt.parse(e.round().toString());
  BigInt nBig = BigInt.parse(n.round().toString());
  BigInt encryptedBig = gradeBig.modPow(eBig, nBig);
  return encryptedBig.toString();
}
