import 'dart:math';
import 'package:gradecryptmobile/test.dart';
import 'package:ninja_prime/ninja_prime.dart';
import 'dart:core';
import 'cantor.dart';
import 'package:shared_preferences/shared_preferences.dart';

var d;
var e;
//create main function
var key_public;
var key_private;
void ckeys() {
  //create a random prime number
  var p = randomPrimeBigInt(12);
  var q = randomPrimeBigInt(13);
  while (p == q) {
    q = randomPrimeBigInt(13);
  }
  var n = p * q;
  e = randomPrimeBigInt(6);
  var m = (p - BigInt.from(1)) * (q - BigInt.from(1));
  void rerune() {
    while (e > m) {
      e = randomPrimeBigInt(8);
      while (e.gcd(m) != 1) {
        e = randomPrimeBigInt(9);
      }
    }
  }

  rerune();
  gend() {
    try {
      d = e.modInverse(m);
    } catch (execption) {
      rerune();
      gend();
    }
  }

  gend();

  var dmgcd = (d.gcd(m));
  while (dmgcd != BigInt.from(1) || BigInt.from(0) > d || d > m) {
    d = d + m;
    dmgcd = (d.gcd(m));
  }
  double result1 = cantor(e.toDouble(), n.toDouble());
  var key_publicTest = int.parse(result1.floor().toString());

  double resultd = cantor(d.toDouble(), n.toDouble());
  var key_privateTest = int.parse(resultd.floor().toString());
  if (testSuccess(key_publicTest, key_privateTest) == false) {
    GetKeys();
  } else {
    key_private = key_privateTest;
    key_public = key_publicTest;
  }
}

void GetKeys() {
  ckeys();
}
