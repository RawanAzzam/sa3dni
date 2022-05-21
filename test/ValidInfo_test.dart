import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/services/authenticateService.dart';
import 'package:flutter_test/flutter_test.dart';

Future <void> main() async {
  test("inValid Info", ()async{
    final FirebaseAuth _firebaseAuth= FirebaseAuth.instance;
    const email=null;
    const pass=null;
    final tes=AuthenticateService();
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: pass);
    const ExpectedValue=false;
    expect(result, ExpectedValue);


  });
  //*****************************************************************************

  test("Valid Info", ()async{
    final FirebaseAuth _firebaseAuth= FirebaseAuth.instance;
    String email="";
    String pass="";
    final tes=AuthenticateService();
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: pass);
    const ExpectedValue=false;
    expect(result, ExpectedValue);

  });
}