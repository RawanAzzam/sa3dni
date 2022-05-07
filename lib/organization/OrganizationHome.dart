import 'package:flutter/material.dart';
import 'package:sa3dni_app/organization/appointmentRequestList.dart';
import 'package:sa3dni_app/organization/eventList.dart';
import 'package:sa3dni_app/organization/organizationChat.dart';
import 'package:sa3dni_app/organization/organizationProfile.dart';
import 'package:sa3dni_app/organization/organizationSetting.dart';
import 'package:sa3dni_app/organization/requestList.dart';
import 'package:sa3dni_app/services/authenticateService.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:sa3dni_app/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category.dart';
import '../models/organization.dart';
import '../patient/settings.dart';

class OrganizationHome extends StatefulWidget {
  const OrganizationHome({Key? key}) : super(key: key);

  @override
  _OrganizationHomeState createState() => _OrganizationHomeState();
}

class _OrganizationHomeState extends State<OrganizationHome> with TickerProviderStateMixin {
  final AuthenticateService _authenticateService = AuthenticateService();
  late TabController _tabController;
  final currentUser = FirebaseAuth.instance.currentUser;
  Organization? _organization;
  int connectionRequestCount = 0;
  int appointmentRequestCount = 0;
  int eventCount = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.animateTo(1);
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
          });
        }
      }
    });

    FirebaseFirestore.instance
        .collection('requests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['organizationID'].toString().contains(currentUser!.uid) &&
            doc['status'].toString().contains('waiting')) {
          setState(() {
          connectionRequestCount++;
          });
        }
      }});

    FirebaseFirestore.instance
        .collection('appointments')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["organizationId"].toString().contains(currentUser!.uid)
            && doc['status'].toString().contains('waiting')) {
          setState(() {
            appointmentRequestCount++;
          });
        }
      }
    });

    FirebaseFirestore.instance
        .collection('events')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["organizationID"].toString().contains(currentUser!.uid)) {
          setState(() {
            eventCount++;
          });
        }
      }
    });

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ConstData().basicColor,
      appBar: AppBar(
        title: const Text('Home'),
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
          children:  const [
            OrganizationProfile(),
            OrganizationChat(),
          ]
      ),
      bottomNavigationBar:
      TabBar(

          controller: _tabController,
          tabs: const [

            Tab(
              icon: Icon(Icons.person),
              text: 'My Profile',
            ),
            Tab(
              icon: Icon(Icons.chat_bubble),
              text: 'Chat',
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
                       CircleAvatar(backgroundImage:NetworkImage(_organization!= null ?
                       _organization!.image:
                       'https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png'),
                          radius: 30,
                          backgroundColor: Colors.white),
                      const SizedBox(height: 10,),
                      Text(_organization != null ?_organization!.name : "name",
                        style: const TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 15,
                            letterSpacing: 3,
                            color: Colors.white
                        ),),
                      const SizedBox(height: 10,),
                      Text(_organization != null ?_organization!.email : "email@gmail.com",
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
                leading: const Icon(Icons.event),
                title: Row(
                  children: [
                    const Text('Events'),
                    const SizedBox(width: 10,),
                    Text(eventCount != 0 ? eventCount.toString() : '',
                    style: const TextStyle(color: Colors.red),)
                  ],
                ),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>   EventList(id: currentUser!.uid),
                  ));

                },
              ),
              ListTile(
                leading: const Icon(Icons.group_add),
                title: Row(
                  children: [
                    const Text('Connection Request'),
                    const SizedBox(width: 10,),
                    Text(connectionRequestCount != 0 ? connectionRequestCount.toString() : '',style: const TextStyle(color: Colors.red),)
                  ],
                ),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>  const RequestList(),
                  ));

                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Row(
                  children: [
                    const Text('Appointment Request'),
                    const SizedBox(width: 10,),
                    Text(appointmentRequestCount != 0 ? appointmentRequestCount.toString() : '',
                       style: const TextStyle(color: Colors.red),)
                  ],
                ),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>  const AppointmentRequestList(),
                  ));

                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>  const OrganizationSetting(),
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
