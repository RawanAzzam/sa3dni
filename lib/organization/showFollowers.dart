import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category.dart';
class ShowFollowers extends StatefulWidget {
  const ShowFollowers({Key? key}) : super(key: key);

  @override
  _ShowFollowersState createState() => _ShowFollowersState();
}

class _ShowFollowersState extends State<ShowFollowers> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Patient> patients = <Patient>[];
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {

         Patient _patient = Patient(
              name: doc['name'],
              category: Category(name: doc['category']),
              email: doc['email'],
              id: doc['id']);
          _patient.phoneNumber = doc['phoneNumber'];
          _patient.image = doc['image'];
          _patient.address = doc['address'];
          _patient.contactPrivacy = doc['contactPrivacy'];
          _patient.addressPrivacy = doc['addressPrivacy'];
          _patient.level = doc['level'];
          patients.add(_patient);
        });

      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  print(currentUser!.uid);
                  DocumentSnapshot userData = snapshot.data!.docs[index];
                  if (userData['organizationID'].toString().contains(currentUser!.uid)
                      && userData['status'].toString().contains('accepted')) {

                    Patient? patient;
                    if(getPatient(userData['patientId']) != null) {
                      patient = getPatient(userData['patientId'])!;
                      print('currentUser!.uid');
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              10.0, 20.0, 10.0, 10.0),
                          child: ListTile(
                              title: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 13, 0, 5),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Name : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                          fontFamily: 'DancingScript'),
                                    ),
                                    Text(
                                      patient != null ?
                                      patient.name : 'name' ,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontFamily: 'DancingScript'),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Address : ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.0,
                                              fontFamily: 'OpenSans'),
                                        ),
                                        (patient != null
                                            && patient.address.isNotEmpty
                                            && patient.addressPrivacy)?
                                        Text(
                                          patient.address ,
                                          style: const TextStyle(
                                              fontSize: 13.0,
                                              fontFamily: 'OpenSans'),
                                        ):const Icon(Icons.lock,size: 15,color: Colors.grey,)
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        const Text(
                                          'Email : ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.0,
                                              fontFamily: 'OpenSans'),
                                        ),
                                        (patient != null
                                           && patient.contactPrivacy)?
                                        Text(
                                          patient.email ,
                                          style: const TextStyle(
                                              fontSize: 13.0,
                                              fontFamily: 'OpenSans'),
                                        ):const Icon(Icons.lock,size: 15,color: Colors.grey,)
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        const Text(
                                          'Phone Number : ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.0,
                                              fontFamily: 'OpenSans'),
                                        ),
                                        (patient != null
                                             && patient.phoneNumber.isNotEmpty
                                            && patient.contactPrivacy)?
                                        Text(
                                          patient.phoneNumber ,
                                          style: const TextStyle(
                                              fontSize: 13.0,
                                              fontFamily: 'OpenSans'),
                                        ):const Icon(Icons.lock,size: 15,color: Colors.grey,)
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        const Text(
                                          'Level : ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13.0,
                                              fontFamily: 'OpenSans'),
                                        ),
                                        (patient != null
                                            && patient.level.isNotEmpty)?
                                        Text(
                                          patient.level ,
                                          style: const TextStyle(
                                              fontSize: 13.0,
                                              fontFamily: 'OpenSans'),
                                        ):const Text('Not take a quiz yet')
                                      ],
                                    ),


                                  ],
                                ),
                              ),
                              leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    patient != null && patient.image.isNotEmpty?
                                    patient.image:
                                    'https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png',
                                  ),
                                  backgroundColor: Colors.white)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                             FlatButton.icon(
                              onPressed: () async {
                                (patient != null
                                    && patient.phoneNumber.isNotEmpty
                                    && patient.contactPrivacy)?
                                    _makePhoneCall(patient.phoneNumber)
                                    :   Fluttertoast.showToast(
                                    msg: "Can't contact with this patient by Phone number ...",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              },
                              icon: const Icon(
                                Icons.call,
                                color: Colors.green,
                              ),
                              label: const Text('Call'),
                            ), const SizedBox(
                              width: 15,
                            ),
                            FlatButton.icon(
                              onPressed: () async {
                                (patient != null
                                    && patient.phoneNumber.isNotEmpty
                                    && patient.contactPrivacy)?
                                sendMessage(patient.phoneNumber)
                                    :   Fluttertoast.showToast(
                                    msg: "Can't contact with this patient by Phone number ...",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              },
                              icon: const Icon(
                                Icons.sms,
                                color: Colors.blue,
                              ),
                              label: const Text('SMS'),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            FlatButton.icon(
                              onPressed: () async {
                                (patient != null
                                    && patient.contactPrivacy)?
                                sendEmail(patient.email)
                                    :   Fluttertoast.showToast(
                                    msg: "Can't contact with this patient by Email...",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );
                              },
                              icon: const Icon(
                                Icons.email,
                                color: Colors.red,
                              ),
                              label: const Text('Email'),
                            )
                          ],
                        ),
                        Divider(
                          color: ConstData().basicColor,
                          height: 20.0,
                          endIndent: 30.0,
                          indent: 30.0,
                        )
                      ],
                    );
                  } else {
                    return const SizedBox(
                      height: 0,
                    );
                  }
                });
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 30),
              child: Card(
                child: ListTile(
                  title: Column(
                    children: <Widget>[
                      Icon(
                        Icons.tag_faces,
                        color: Theme.of(context).primaryColor,
                        size: 35.0,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      const Text(
                        "No Record Found",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18.0, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Patient? getPatient(String id){
    print(patients.length.toString());
    for(Patient patient in patients) {
      if(patient.id.toString().contains(id)) {
        return patient;
      }
    }
    return null;
  }
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> sendMessage(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(launchUri);
  }
}
