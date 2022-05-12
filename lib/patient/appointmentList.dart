import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';
import '../models/organization.dart';
class AppointmentList extends StatefulWidget {
   const AppointmentList({Key? key}) : super(key: key);

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  final currentUser = FirebaseAuth.instance.currentUser;
   List<Organization> organizations = [];
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('organization')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        
            setState(() {
              organizations.add(
                // address , category , email , name , phoneNumber , rate
                  Organization(name: doc['name'],
                      phoneNumber: doc['phoneNumber'],
                      address: doc['address'],
                      category: Category(name: doc['category']),
                      email: doc['email'],
                      id: doc['id'],
                      image: doc['image']));
            });
                 

      }
    });
 
  }
  
  String getOrganizationImage(String id){
    for(Organization organization in organizations){
      if(organization.id == id){
        return organization.image;
      }
    }
    return '';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment'),
        backgroundColor: ConstData().basicColor,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return  ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot userData =
                    snapshot.data!.docs[index];
                    if(userData['patientId'].toString().compareTo(currentUser!.uid) == 0
                    && userData['status'].toString().compareTo('confirm') == 0){
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                        child: ListTile(
                          title: Row(
                            children:  [
                              const Text('Name : ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    fontFamily: 'DancingScript'
                                ),),
                              Text(userData['organizationName'],
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: 'DancingScript'
                                ),),
                            ],
                          ),
                          leading:CircleAvatar(backgroundImage: NetworkImage(
                              getOrganizationImage(userData['organizationId'])),
                            backgroundColor: Colors.white,),
                         subtitle: Column(
                           children: [
                             Row(
                               children:  [
                                 const Text('Date : ',
                                   style: TextStyle(
                                       fontWeight: FontWeight.bold,
                                       fontSize: 15.0,
                                   ),),
                                 Text(userData['date'],
                                   style: TextStyle(
                                       fontSize: 15.0,
                                   ),),
                               ],
                             ),
                             SizedBox(height: 2,),
                             Row(
                               children:  [
                                 const Text('Time : ',
                                   style: TextStyle(
                                       fontWeight: FontWeight.bold,
                                       fontSize: 15.0,
                                   ),),
                                 Text(userData['time'],
                                   style: TextStyle(
                                       fontSize: 15.0,
                                   ),),
                               ],
                             ),
                           ],
                         ),
                        )  ,


                      );
                    }else{
                      return SizedBox();
                    }

                  }
              );
            } else {
              return  Container(
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
      ),
    );
  }
}
