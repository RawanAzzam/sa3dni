import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:sa3dni_app/services/databaseServicesPatient.dart';
import 'package:sa3dni_app/shared/constData.dart';
import '../../models/category.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/DatabaseServiceOrga.dart';
import '../../services/uploadFile.dart';
import '../../shared/inputField.dart';
class PrivacyAndPolicyPatient extends StatefulWidget {
  const PrivacyAndPolicyPatient({Key? key}) : super(key: key);

  @override
  _PrivacyAndPolicyPatientState createState() => _PrivacyAndPolicyPatientState();
}

class _PrivacyAndPolicyPatientState extends State<PrivacyAndPolicyPatient> {
  Patient? _patient;
  final currentUser = FirebaseAuth.instance.currentUser;
  UploadFile uploadFile = UploadFile();
  bool contactPrivacy = false;
  bool addressPrivacy = false;



  @override
  void initState() {
    super.initState();
    updateInfo();
  }

  updateInfo() {
    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["id"].toString().contains(currentUser!.uid)) {
          setState(() {
            _patient = Patient(
                name: doc['name'],
                category: Category(name: doc['category']),
                email: doc['email'],
                id: doc['id']);
            _patient!.phoneNumber = doc['phoneNumber'];
            _patient!.image = doc['image'];
            _patient!.address = doc['address'];
            _patient!.addressPrivacy = doc['addressPrivacy'];
            _patient!.contactPrivacy = doc['contactPrivacy'];
            _patient!.level = doc['level'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        title: const Text('Settings'),
      ),
      body: _patient != null ? Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Row(
                children: const [
                  SizedBox(width: 10,),
                  Icon(Icons.local_police, color: Colors.black,),
                  SizedBox(width: 10,),
                  Text(
                    'Privacy & Policy',
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),)
                ],
              ),
            ),
            const Divider(height: 20, thickness: 2,),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: ListTile(
                  leading:const Icon(Icons.contact_support_sharp, color: Colors.amberAccent),
                  title: const Text('Allow Organization to see your Email And Phone Number'),
                  trailing:    Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      activeColor: ConstData().basicColor,
                      trackColor: Colors.grey,
                      value: contactPrivacy,
                      onChanged: (bool newValue) {
                        setState(() {
                          contactPrivacy = newValue;
                          DatabaseServicePatient().
                          updatePatientPrivacy(_patient!, contactPrivacy, addressPrivacy);
                        });
                      },
                    ),
                  ),
                )
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading:const Icon(Icons.location_on_outlined, color: Colors.blue),
                  title: const Text('Allow Organization to see your Location'),
                  trailing:    Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      activeColor: ConstData().basicColor,
                      trackColor: Colors.grey,
                      value: addressPrivacy,
                      onChanged: (bool newValue) {
                        setState(() {
                          addressPrivacy = newValue;
                          DatabaseServicePatient().
                          updatePatientPrivacy(_patient!, contactPrivacy, addressPrivacy);
                        });
                      },
                    ),
                  ),
                )





            ),
          ],
        ),
      ) :
      SpinKitFadingCircle(
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.green,
            ),
          );
        },
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


}
