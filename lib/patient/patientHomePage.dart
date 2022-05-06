import 'package:flutter/material.dart';
import 'package:sa3dni_app/organization/organizationList.dart';
import 'package:sa3dni_app/patient/chat.dart';
import 'package:sa3dni_app/patient/patientProfile.dart';
import 'package:sa3dni_app/patient/quizPage.dart';
import 'package:sa3dni_app/patient/settings.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
              },
              child: const Icon(Icons.notifications,color: Colors.white,)

          )
        ],
      ),
      body: TabBarView(
          controller: _tabController,
          children: const [
          OrganizationList(),
          PatientProfile(),
          ChatPage(),
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
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       const Image(image:const AssetImage('assets/logo.png'),
                           width: 120,
                           color: Colors.white),
                        const SizedBox(height: 10,),
                        Text(patient != null ?patient!.name : "name",
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 15,
                          letterSpacing: 3,
                          color: Colors.white
                        ),),
                        SizedBox(height: 10,),
                        Text(patient != null ?patient!.email : "email@gmail.com",
                          style: const TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 10,
                              color: Colors.white
                          ),)
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Appointment'),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>   AppointmentList(),
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
                      builder: (context) =>  const SettingsPage(),
                    ));

                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment_return_outlined,),
                  title: const Text('SingOut'),
                  onTap: (){
                    _authenticateService.singOut();
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
}
