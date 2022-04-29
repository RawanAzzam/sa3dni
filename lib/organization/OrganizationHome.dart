import 'package:flutter/material.dart';
import 'package:sa3dni_app/organization/eventPage.dart';
import 'package:sa3dni_app/organization/organizationChat.dart';
import 'package:sa3dni_app/organization/organizationProfile.dart';
import 'package:sa3dni_app/services/authenticateService.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:sa3dni_app/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category.dart';
import '../models/organization.dart';
import '../patient/chat.dart';
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
          children:  [

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
                      SizedBox(height: 10,),
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
                title: const Text('Add Event'),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>  const EventPage(),
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
