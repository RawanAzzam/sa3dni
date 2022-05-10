import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:sa3dni_app/models/request.dart';
import 'package:sa3dni_app/services/databaseServicesNotification.dart';
import 'package:sa3dni_app/services/databaseServicesRequests.dart';

import '../shared/constData.dart';
class RequestList extends StatefulWidget {
  const RequestList({Key? key}) : super(key: key);

  @override
  _RequestListState createState() => _RequestListState();
}

class _RequestListState extends State<RequestList> {
  final currentUser = FirebaseAuth.instance.currentUser;
  Organization? organization;
  List<Request> requests = <Request>[];
  List<Patient> patients = <Patient>[];
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('organization')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if(doc['id'].toString().contains(currentUser!.uid)) {
          setState(() {
          organization =
              Organization(
                  name: doc['name'],
                  phoneNumber: doc['phoneNumber'],
                  address: doc['address'],
                  category: Category(name: doc['category']),
                  email: doc['email'],
                  id: doc['id'],
                  image: doc['image']);
        });
        }

      }
    });
    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {

          setState(() {
            patients.add(Patient(
                name: doc['name'],
                email: doc['email'],
                category:Category(name: doc['category']),
                id: doc['id']));
          });

      }
    });

  }
  @override
  Widget build(BuildContext context) {


      return Scaffold(
        appBar: AppBar(
          title: const Text('Connection Request'),
          backgroundColor: ConstData().basicColor,
        ),
        body:StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('requests').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return  ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot userData =
                    snapshot.data!.docs[index];

                    if (userData["organizationID"].toString().contains(currentUser!.uid)
                        && userData['status'].toString().contains('waiting')){
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                                border:
                                Border.all(color: ConstData().basicColor, width: 1)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  ListTile(
                                   leading:  CircleAvatar(backgroundImage:
                                  const NetworkImage('https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png'),
                                     backgroundColor: Colors.grey[200],
                                       ),
                                    title: Text(getPatient(userData['patientId']) != null ?
                                    getPatient(userData['patientId'])!.name : 'name'),
                                    subtitle:Text('Category :' +(
                                        getPatient(userData['patientId']) != null ?
                                    getPatient(userData['patientId'])!.category.name : 'category')) ,

                                 ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RaisedButton(
                                          onPressed: () async{
                                            await   DatabaseServicesRequests().
                                            updateStatus(userData.id, 'accepted',
                                                userData['patientId'],
                                                userData['organizationID']);
                                            await DatabaseServiceNotification()
                                            .addConnectionAcceptNotify(organization!, userData['patientId']);
                                            setState(() {

                                            });
                                          },
                                          child: const Text('Accept'),
                                        color: ConstData().secColor,

                                      ),
                                      const SizedBox(width: 20,),
                                      RaisedButton(
                                          onPressed: () async{
                                            await   DatabaseServicesRequests().
                                            updateStatus(userData.id, 'rejected',
                                                userData['patientId'],
                                                userData['organizationID']);
                                            setState(() {

                                            });
                                          },
                                         child: const Text('Reject'),
                                     )
                                    ],
                                  )

                                ],
                              )
                            )
                        )
                      ) ;
                    }else{
                      return const Divider(height: 0,thickness: 0,);
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
                          style: TextStyle(fontSize: 18.0, color: Colors.black87),
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
    for(Patient patient in patients) {
      if(patient.id == id) {
        return patient;
      }
    }
    return null;

  }
  }

