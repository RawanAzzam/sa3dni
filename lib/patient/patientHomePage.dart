import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sa3dni_app/organization/organizationList.dart';
import 'package:sa3dni_app/patient/chat.dart';
import 'package:sa3dni_app/patient/notification.dart';
import 'package:sa3dni_app/patient/organizationPosts.dart';
import 'package:sa3dni_app/patient/patientProfile.dart';
import 'package:sa3dni_app/patient/quizPage.dart';
import 'package:sa3dni_app/patient/searchOrganization.dart';
import 'package:sa3dni_app/patient/settings/settings.dart';
import 'package:sa3dni_app/services/authenticateService.dart';
import 'package:sa3dni_app/services/pushNotifications.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/organization.dart';
import '../models/patient.dart';
import '../wrapper.dart';
import 'package:sa3dni_app/models/category.dart' as C;
import 'appointmentList.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  _PatientHomeState createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome>
    with TickerProviderStateMixin {
  final AuthenticateService _authenticateService = AuthenticateService();
  late TabController _tabController;
  Patient? patient;
  List<Organization> organizations = <Organization>[];

  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();

    PushNotifications();

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
                category: C.Category(name: doc['category']),
                id: doc['id']);
          });
        }
      }
    });

    updateInfo();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.animateTo(1);
  }

  updateInfo() {
    FirebaseFirestore.instance
        .collection('organization')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          organizations.add(Organization(
              name: doc['name'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstData().basicColor,
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        actions: [
          FlatButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: DataSearch(organizations: organizations),
                );
              },
              child: const Icon(
                Icons.search,
                color: Colors.white,
              )),
          FlatButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const NotificationPatient(),
                ));
              },
              child: const Icon(
                Icons.notifications,
                color: Colors.white,
              )),
        ],
      ),
      body: TabBarView(controller: _tabController, children: [
        OrganizationPosts(
            category: patient != null ? patient!.category.name : 'Smoking'),
        const OrganizationList(),
        const PatientProfile(),
        const ChatPage(),
      ]),
      bottomNavigationBar: TabBar(controller: _tabController, tabs: const [
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
      ]),
      drawer: Drawer(
          child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: ConstData().basicColor,
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('patients').snapshots(),
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
                                const Image(
                                    image: const AssetImage('assets/logo.png'),
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
                          return const SizedBox();
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
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AppointmentList(),
              ));
            },
          ),
          ListTile(
            leading: const Text(
              " ?",
              style: TextStyle(fontSize: 25, color: Color(0xFF757575)),
            ),
            title: const Text('Take a Screening'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const Quiz(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const SettingPage(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.assignment_return_outlined,
            ),
            title: const Text('SingOut'),
            onTap: () async {
              await _authenticateService.singOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const Wrapper(),
              ));
            },
          ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class DataSearch extends SearchDelegate<String> {
  List<Organization> organizations = <Organization>[];

  DataSearch({required this.organizations});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, '');
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? []
        : organizations.where((p) => p.name.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(suggestionList[index].image),
          ),
          title: Text(suggestionList[index].name),
          subtitle: Text("Location :"+suggestionList[index].address)
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? []
        : organizations.where((p) => p.name.startsWith(query)).toList();
    print(organizations.where((p) => p.name.startsWith(query)));
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          showResults(context);
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(organizations[index].image),
        ),
        title: RichText(
          text: TextSpan(
            text: suggestionList[index].name.substring(0, query.length),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: suggestionList[index].name.substring(query.length),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      itemCount: suggestionList.length,
    );
  }
}
