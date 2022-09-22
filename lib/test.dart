import 'dart:math';

import 'package:gradecryptmobile/main.dart';

var correct_grade;

bool testSuccess(BigInt n, BigInt e, BigInt d) {
  Random random = new Random();
  int grade = random.nextInt(7) * 100;
  while (grade == 0) {
    int grade = random.nextInt(7) * 100;
  }
  var encrypted = BigInt.parse(rsa(grade.toString(), e, n));
  var decrypted = encrypted.modPow(d, n);
  if (int.parse(decrypted.toString()) == grade) {
    return true;
  } else {
    print("rerun");
    return false;
  }
}

String rsa(String grade, BigInt e, BigInt n) {
  var gradeDouble = double.parse(grade);
  var gradeInt = int.parse((gradeDouble).round().toString());
  BigInt gradeBig = BigInt.parse(gradeInt.toString());
  BigInt eBig = BigInt.parse(e.toString());
  BigInt nBig = BigInt.parse(n.toString());
  BigInt encryptedBig = gradeBig.modPow(eBig, nBig);
  return encryptedBig.toString();
}
