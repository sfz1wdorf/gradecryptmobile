import 'dart:convert';
import 'dart:math';

import 'package:gradecryptmobile/main.dart';
import 'package:gradecryptmobile/test.dart';
import 'package:ninja_prime/ninja_prime.dart';
import 'dart:core';

var d;
var e;
//create main function
var key_public;
var key_private;
var key_public_show;
void ckeys() {
  Random rnd;
  int min = 57;
  int max = 58;
  rnd = new Random();
  var r = min + rnd.nextInt(max - min);

  //create a random prime number
  BigInt p = randomPrimeBigInt(r);
  BigInt q = randomPrimeBigInt(r + 1);
  while (p == q) {
    q = randomPrimeBigInt(r + 1);
  }
  BigInt n = p * q;
  e = randomPrimeBigInt(54);
  BigInt m = (p - BigInt.from(1)) * (q - BigInt.from(1));
  void rerune() {
    while (e > m) {
      e = randomPrimeBigInt(54);
      while (e.gcd(m) != 1) {
        e = randomPrimeBigInt(55);
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

  BigInt dmgcd = (d.gcd(m));
  while (dmgcd != BigInt.from(1) || BigInt.from(0) > d || d > m) {
    d = d + m;
    dmgcd = (d.gcd(m));
  }
  while (testSuccess(n, e, d) == false) {
    ckeys();
  }
  key_private = "$d'$n";
  print(key_private);
  key_public = "$e'$n";
  print(key_public);
  key_public_show =
      "${BigInt.parse(e.toString()).toRadixString(36)}'${n.toRadixString(36)}";
  //final strBytes = utf8.encode(key_public_show);
  //final base64String = base64.encode(strBytes);
  //key_public_show = base64String;
}

void GetKeys() {
  ckeys();
}
