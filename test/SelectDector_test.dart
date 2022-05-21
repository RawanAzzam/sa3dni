import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sa3dni_app/Home/selectCategory.dart';
import 'package:sa3dni_app/models/category.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

Future <void> main() async {
  FirebaseApp firebaseApp;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    firebaseApp = MockFirebaseApp();
  });
  test("Select Dector", (){
    const ispw=false;
    final tes=SelectCategory(isPatient: ispw,);
    final result=tes.isPatient==false;
    const expectedOutput=false;
    expect(result, expectedOutput);

  });


  test("Select Dector", (){
    const ispw=true;
    final tes=SelectCategory(isPatient: ispw,);
    final result=tes.isPatient==false;
    const expectedOutput=true;
    expect(result, expectedOutput);

  });
}