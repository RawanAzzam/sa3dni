import 'package:flutter/material.dart';
import 'package:sa3dni_app/organization/appointmentRequestList.dart';
import 'package:sa3dni_app/organization/eventList.dart';
import 'package:sa3dni_app/organization/organizationChat.dart';
import 'package:sa3dni_app/organization/organizationProfile.dart';
import 'package:sa3dni_app/organization/requestList.dart';
import 'package:sa3dni_app/services/authenticateService.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:sa3dni_app/wrapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Setting/organizationSetting.dart';

class OrganizationHome extends StatefulWidget {
  const OrganizationHome({Key? key}) : super(key: key);

  @override
  _OrganizationHomeState createState() => _OrganizationHomeState();
}

class _OrganizationHomeState extends State<OrganizationHome>
    with TickerProviderStateMixin {
  final AuthenticateService _authenticateService = AuthenticateService();
  late TabController _tabController;
  final currentUser = FirebaseAuth.instance.currentUser;
  int connectionRequestCount = 0;
  int appointmentRequestCount = 0;
  int eventCount = 0;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.animateTo(1);


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
      }
    });

    FirebaseFirestore.instance
        .collection('appointments')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["organizationId"].toString().contains(currentUser!.uid) &&
            doc['status'].toString().contains('waiting')) {
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
              onPressed: () {},
              child: const Icon(
                Icons.notifications,
                color: Colors.white,
              ))
        ],
      ),
      body: TabBarView(controller: _tabController, children: const [
        OrganizationProfile(),
        OrganizationChat(),
      ]),
      bottomNavigationBar: TabBar(controller: _tabController, tabs: const [
        Tab(
          icon: Icon(Icons.person),
          text: 'My Profile',
        ),
        Tab(
          icon: Icon(Icons.chat_bubble),
          text: 'Chat',
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
              stream: FirebaseFirestore.instance
                  .collection('organization')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                    DocumentSnapshot userData =
                    snapshot.data!.docs[index];
if(userData['id'].toString().contains(currentUser!.uid)) {
  return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                              backgroundImage: NetworkImage(
                          userData['image'])
                          ,radius: 30,
                              backgroundColor: Colors.white),
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
}
else{
  return SizedBox();
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
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: Row(
              children: [
                const Text('Events'),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  eventCount != 0 ? eventCount.toString() : '',
                  style: const TextStyle(color: Colors.red),
                )
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EventList(id: currentUser!.uid),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: Row(
              children: [
                const Text('Connection Request'),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  connectionRequestCount != 0
                      ? connectionRequestCount.toString()
                      : '',
                  style: const TextStyle(color: Colors.red),
                )
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const RequestList(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: Row(
              children: [
                const Text('Appointment Request'),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  appointmentRequestCount != 0
                      ? appointmentRequestCount.toString()
                      : '',
                  style: const TextStyle(color: Colors.red),
                )
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AppointmentRequestList(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const OrganizationSetting(),
              ));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.assignment_return_outlined,
            ),
            title: const Text('SingOut'),
            onTap: () {
              _authenticateService.singOut();
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
