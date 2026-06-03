// ignore_for_file: camel_case_types, unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class customInputDecoration extends StatefulWidget {
  const customInputDecoration({super.key});

  @override
  State<customInputDecoration> createState() => _customInputDecorationState();
}

class _customInputDecorationState extends State<customInputDecoration> {
  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(9.0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
        borderRadius: BorderRadius.all(Radius.circular(9.0)),
      ),
      fillColor: Colors.grey.shade200,
      filled: true,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
