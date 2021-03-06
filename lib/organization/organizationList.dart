import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/patient/viewOrganizationProfile.dart';
import 'package:sa3dni_app/services/databaseServicesNotification.dart';
import 'package:sa3dni_app/services/databaseServicesRequests.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient.dart';
import '../models/request.dart';
import 'package:shimmer/shimmer.dart';

class OrganizationList extends StatefulWidget {
  const OrganizationList({Key? key}) : super(key: key);

  @override
  State<OrganizationList> createState() => _OrganizationListState();
}

class _OrganizationListState extends State<OrganizationList> {
  final currentUser = FirebaseAuth.instance.currentUser;
  Patient? _patient;
  List<Organization> organizations = <Organization>[];
  List<Request> requests = <Request>[];
  Timer? timer;
  @override
  void initState() {
    super.initState();
    getPatient();
    changeStatus();
  }

  void getPatient() {
    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['id'].toString().contains(currentUser!.uid)) {
          setState(() {
            _patient = Patient(
                name: doc['name'],
                email: doc['email'],
                category: Category(name: doc['category']),
                id: doc['id']);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_patient != null) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('organization')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot userData = snapshot.data!.docs[index];
                      if (userData['category']
                          .toString()
                          .contains(_patient!.category.name)) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  10.0, 20.0, 10.0, 10.0),
                              child: ListTile(
                                  title: Row(
                                    children: [
                                      const Text(
                                        'Name : ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                            fontFamily: 'DancingScript'),
                                      ),
                                      Text(
                                        userData['name'],
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontFamily: 'DancingScript'),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Address : ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                                fontFamily: 'DancingScript'),
                                          ),
                                          Text(
                                            userData['address'],
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontFamily: 'DancingScript'),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Rate : ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                                fontFamily: 'DancingScript'),
                                          ),
                                          Text(
                                            userData['rate'],
                                            style: const TextStyle(
                                                fontSize: 15.0,
                                                fontFamily: 'DancingScript'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        userData['image'],
                                      ),
                                      backgroundColor: Colors.white)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FlatButton.icon(
                                    onPressed: () async {
                                      if (getStatus(userData.id)
                                              .contains('nothing') ||
                                          getStatus(userData.id)
                                              .contains('rejected')) {
                                        await DatabaseServicesRequests()
                                            .addRequest(
                                                currentUser!.uid, userData.id);
                                        await DatabaseServiceNotification()
                                        .addConnectionRequestNotify(_patient!, userData['id']
                                            ,userData['deviceToken']);
                                        changeStatus();
                                      } else if (getStatus(userData.id)
                                          .contains('waiting')) {
                                        await DatabaseServicesRequests()
                                            .deleteRequest(getId(userData.id));
                                        await DatabaseServiceNotification()
                                        .removeConnectionRequest(_patient!.id, userData['id']);
                                        changeStatus();
                                      }
                                    },
                                    icon: Icon(
                                      getStatus(userData.id).contains('waiting')
                                          ? Icons.cancel
                                          : getStatus(userData.id)
                                                  .contains('accepted')
                                              ? Icons.person
                                              : Icons.group_add,
                                      color: Colors.blue,
                                    ),
                                    label: Text(getStatus(userData.id)
                                            .contains('waiting')
                                        ? 'cancel'
                                        : getStatus(userData.id)
                                                .contains('accepted')
                                            ? 'Following'
                                            : 'request')),
                                const SizedBox(
                                  width: 15,
                                ),
                                FlatButton.icon(
                                  onPressed: () async {
                                    Organization organization = Organization(
                                        name: userData['name'],
                                        phoneNumber: userData['phoneNumber'],
                                        address: userData['address'],
                                        category: Category(
                                            name: userData['category']),
                                        email: userData['email'],
                                        id: userData['id'],
                                        image: userData['image']);
                                    print(userData['deviceToken']);
                                    organization.deviceToken = userData['deviceToken'];
                                    organization.contactPrivacy = userData['contactPrivacy'];
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          ViewOrganizationProfile(
                                              organization: organization,
                                              status: getStatus(userData.id)),
                                    ));
                                  },
                                  icon: const Icon(
                                    Icons.account_circle,
                                    color: Colors.red,
                                  ),
                                  label: const Text('View Profile'),
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
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
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

  String getStatus(String organizationId) {
    print(organizationId);
    for (var request in requests) {
      if (request.patientId == currentUser!.uid &&
          request.organizationId == organizationId) {
        return request.status;
      }
    }
    return 'nothing';
  }

  String getId(String organizationId) {
    for (var request in requests) {
      if (request.patientId == currentUser!.uid &&
          request.organizationId == organizationId) {
        return request.id;
      }
    }
    return '';
  }

  void changeStatus() {
    requests = [];
    FirebaseFirestore.instance
        .collection('requests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          requests.add(Request(
              organizationId: doc['organizationID'],
              patientId: doc['patientId'],
              status: doc['status'],
              id: doc['id']));
        });
      }
    });
  }
}
