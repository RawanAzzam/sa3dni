import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sa3dni_app/organization/organizationList.dart';
import 'package:sa3dni_app/patient/chat.dart';
import 'package:sa3dni_app/patient/notification.dart';
import 'package:sa3dni_app/patient/organizationPosts.dart';
import 'package:sa3dni_app/patient/patientProfile.dart';
import 'package:sa3dni_app/patient/quizPage.dart';
import 'package:sa3dni_app/patient/settings/settings.dart';
import 'package:sa3dni_app/services/authenticateService.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';
import '../wrapper.dart';
import 'package:sa3dni_app/models/category.dart';

import 'appointmentList.dart';
class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  _PatientHomeState createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> with TickerProviderStateMixin {
  final AuthenticateService _authenticateService = AuthenticateService();
  late TabController _tabController;
  Patient? patient;
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["id"].toString().contains(currentUser!.uid)) {
          setState(() {
            patient = Patient(
                name: doc['name'],
                email: doc['email'],
                category: Category(name: doc['category']),
                id: doc['id']);
          });
        }
      }
    });
    _tabController = TabController(length: 4, vsync: this);
    _tabController.animateTo(1);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstData().basicColor,
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        actions: [

          FlatButton(
              onPressed:() {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                const NotificationPatient(),
                ));
              },
              child: const Icon(Icons.notifications,color: Colors.white,)

          )
        ],
      ),
      body: TabBarView(
          controller: _tabController,
          children:  [
            OrganizationPosts(category: patient !=  null ?
            patient!.category.name : 'Smoking'),
          const OrganizationList(),
          const PatientProfile(),
          const ChatPage(),
                ]
      ),
       bottomNavigationBar:
       TabBar(

           controller: _tabController,
           tabs: const [
             Tab(
               icon: Icon(Icons.home),
             ),
             Tab(
               icon: Icon(Icons.group),
             ),
             Tab(
               icon: Icon(Icons.person),
             ),
             Tab(
               icon: Icon(Icons.chat_bubble),
             ),

           ]

       ),
      drawer: Drawer(

        child:
            ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: ConstData().basicColor,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('patients')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot userData = snapshot.data!.docs[index];
                              if (userData['id']
                                  .toString()
                                  .contains(currentUser!.uid)) {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Image(image:const AssetImage('assets/logo.png'),
                                          width: 120,
                                          color: Colors.white),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        userData['name'],
                                        style: const TextStyle(
                                            fontFamily: 'OpenSans',
                                            fontSize: 15,
                                            letterSpacing: 3,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        userData['email'],
                                        style: const TextStyle(
                                            fontFamily: 'OpenSans',
                                            fontSize: 10,
                                            color: Colors.white),
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                return SizedBox();
                              }
                            });
                      } else {
                        return SpinKitFadingCircle(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: index.isEven ? Colors.red : Colors.green,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Appointment'),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>   const AppointmentList(),
                    ));

                  },
                ),
                ListTile(
                  leading: const Text(" ?",
                  style: TextStyle(fontSize: 25,color:Color(0xFF757575)),),
                  title: const Text('Take a quiz'),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>  const Quiz(),
                    ));

                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>  const SettingPage(),
                    ));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_return_outlined,),
                  title: const Text('SingOut'),
                  onTap: ()async{
                   await _authenticateService.singOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>  const Wrapper(),
                    ));
                  },
                ),

              ],
            )

      ),

    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
