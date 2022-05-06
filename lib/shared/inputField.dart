import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';

var textInputField = InputDecoration(
    hintText:  'Email',
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFDAEFEF),width: 1.0)
    ),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ConstData().basicColor)
    )
);