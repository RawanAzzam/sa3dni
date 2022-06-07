import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sa3dni_app/services/authenticateService.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

Future <void> main() async {
  FirebaseApp firebaseApp;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    firebaseApp = MockFirebaseApp();
  });

  test("Correct Info", (){
   const pass="123456";
   final tes=AuthenticateService().signInWithEmailAndPassword("amani@gmail.com", pass);
   final Expect =AuthenticateService().signInWithEmailAndPassword("amani@gmail.com", pass);
   expect(tes,Expect);

  });




}
