import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sa3dni_app/services/authenticateService.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

Future <void> main() async{
 FirebaseApp firebaseApp;
 setUp(() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  firebaseApp = MockFirebaseApp();
 });

 test("reset Password", (){
  final tes=AuthenticateService().resetPassword("amani@gmail.com");
  final expVal="amani@gmail.com";

  expect(tes,expVal);
 });

 test("not reset Password", (){
  final tes=AuthenticateService().resetPassword("amani@gmail.com");
  final expVal="amani23@gmail.com";

  expect(tes,expVal);
 });








}
