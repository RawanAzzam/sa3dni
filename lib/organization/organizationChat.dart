import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:shimmer/shimmer.dart';
import '../models/request.dart';
import '../shared/constData.dart';
class OrganizationChat extends StatefulWidget {
  const OrganizationChat({Key? key}) : super(key: key);

  @override
  _OrganizationChatState createState() => _OrganizationChatState();
}

class _OrganizationChatState extends State<OrganizationChat> {
  List<Patient> patients = <Patient>[];
  List<Request> requests = <Request>[];
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('requests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['organizationID'].toString().contains(currentUser!.uid) &&
            doc['status'].toString().contains('accepted')) {
          setState(() {
            requests.add(Request(organizationId: doc['organizationID'],
                patientId: doc['patientId'],
                status: doc['status'],
                id: doc['id']));
            FirebaseFirestore.instance
                .collection('patients')
                .get()
                .then((QuerySnapshot querySnapshot) {
              for (var doc in querySnapshot.docs) {
                setState(() {
                  patients.add(
                    // address , category , email , name , phoneNumber , rate
                     Patient(
                         name: doc['name'],
                         email: doc['email'],
                         category: Category(name:doc['category']),
                         id: doc['id']));
                });
              }
            });
          });
        }
      }});

  }
  @override
  Widget build(BuildContext context) {
    if(requests.isNotEmpty && patients.isNotEmpty) {
      return Scaffold(
        body:   Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 10, 0.0),
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context,index){
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            backgroundImage:
                            NetworkImage('https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png'),
                            radius: 25,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 10,),
                          Text(getPatient(requests[index].patientId)!.name)
                        ],
                      ),
                    );
                  },
                  // This next line does the trick.
                  scrollDirection: Axis.horizontal,

                ),
              ),
            ),
            Divider(height: 20,color: ConstData().secColor,endIndent: 10,indent: 10,thickness: 2,),
            const Text('Chats')
          ],
        ),
      );
    }else{
      return Scaffold(
        backgroundColor: Colors.white,
        body:  Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: ListView.builder(
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 48.0,
                            height: 48.0,
                            color: Colors.white,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: 40.0,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    itemCount: 10,
                  ),
                ),
              ),

            ],
          ),
        ),

      );
    }
  }
  Patient? getPatient(String id){

    for(var patient in patients) {
      if(patient.id.contains(id)) {
        return patient;
      }
    }

    return null;
  }
}
