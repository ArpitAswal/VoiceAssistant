import 'package:flutter/material.dart';

Widget bottomSheet({required String msg}) {
  return Container(
      height: 100,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[BoxShadow(color: Colors.tealAccent)]),
      alignment: Alignment.center,
      child: Text(msg,
          style: const TextStyle(
              fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w600)));
}
