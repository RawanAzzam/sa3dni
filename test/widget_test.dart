// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sa3dni_app/Home/selectCategory.dart';


Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

 test("Select patitent Icon ",() {
   const isp=true;
   final tes=SelectCategory(isPatient: isp,);
   final result=tes.isPatient==true;
   const expectedOutput=true;
   expect(result, expectedOutput);
 });


 //*****************************************************************************


 test("Select organization Icon ",() {
   const ispw=false;
   final tes=SelectCategory(isPatient: ispw,);
   final result=tes.isPatient==true;
   const expectedOutput=false;
   expect(result, expectedOutput);
 });



}
