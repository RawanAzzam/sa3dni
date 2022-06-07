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
  test("Choose Category", (){
    var category;
    final tes = SelectCategory(isPatient: true,);
    if (tes.isPatient == true) {
      final result = tes.isPatient == true;
      (category.name = "Smoking") as Category;
      final ExpectedValue = null;
      expect(result, ExpectedValue);

    }

  });
}