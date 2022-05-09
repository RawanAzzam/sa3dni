import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';
import '../../models/category.dart';
import '../../models/organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/DatabaseServiceOrga.dart';
import '../../services/uploadFile.dart';
import '../../shared/inputField.dart';
class PrivacyAndPolicyOrganization extends StatefulWidget {
  const PrivacyAndPolicyOrganization({Key? key}) : super(key: key);

  @override
  _PrivacyAndPolicyOrganizationState createState() => _PrivacyAndPolicyOrganizationState();
}

class _PrivacyAndPolicyOrganizationState extends State<PrivacyAndPolicyOrganization> {
  Organization? _organization;
  bool val1 = true;
  final currentUser = FirebaseAuth.instance.currentUser;
  UploadFile uploadFile = UploadFile();

  onChangeFunction1(bool newValue1) {
    setState(() {
      val1 = newValue1;
    });
  }

  @override
  void initState() {
    super.initState();
    updateInfo();
  }

  updateInfo() {
    FirebaseFirestore.instance
        .collection('organization')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["id"].toString().contains(currentUser!.uid)) {
          setState(() {
            _organization = Organization(
                name: doc['name'],
                phoneNumber: doc['phoneNumber'],
                address: doc['address'],
                category: Category(name: doc['category']),
                email: doc['email'],
                id: doc['id'],
                image: doc['image']);

            _organization!.listOfRate = [];
            FirebaseFirestore.instance
                .collection('rates')
                .doc(_organization!.id)
                .collection('organizationRates')
                .get()
                .then((QuerySnapshot querySnapshot) {
              for (var doc in querySnapshot.docs) {
                setState(() {
                  _organization!.setRate(doc['rate']);
                });
              }
            });
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
      body: Padding(
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
                  title: const Text('Allow Patient to contact By Email And Phone Number'),
                trailing:    Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    activeColor: ConstData().basicColor,
                    trackColor: Colors.grey,
                    value: val1,
                    onChanged: (bool newValue) {
                      onChangeFunction1(newValue);
                      print(val1);
                    },
                  ),
                ),
              )





            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


}
