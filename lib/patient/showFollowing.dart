import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/patient/viewOrganizationProfile.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category.dart';
class ShowFollowing extends StatefulWidget {
  const ShowFollowing({Key? key}) : super(key: key);

  @override
  _ShowFollowingState createState() => _ShowFollowingState();
}

class _ShowFollowingState extends State<ShowFollowing> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Organization> organizations = <Organization>[];
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
                Organization(
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
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot userData = snapshot.data!.docs[index];
                  if (userData['patientId'].toString().contains(currentUser!.uid)
                  && userData['status'].toString().contains('accepted')) {
                    Organization? organization;
                    if(getOrganization(userData['organizationID']) != null) {
                      organization = getOrganization(userData['organizationID'])!;
                    }
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
                                   organization != null ?
                                   organization.name : 'name' ,
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
                                        organization != null ?
                                        organization.address :
                                        'address',
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
                                  organization != null ?
                                    organization.image:
                                    'https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png',
                                  ),
                                  backgroundColor: Colors.white)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           
                            const SizedBox(
                              width: 15,
                            ),
                            FlatButton.icon(
                              onPressed: () async {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (context) =>
                                      ViewOrganizationProfile(
                                          organization: organization!,
                                          status: 'accepted'),
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
    );
  }
  
  Organization? getOrganization(String id){
    for(Organization organization in organizations) {
      if(organization.id.toString().contains(id)) {
        return organization;
      }
    }
    return null;
  }
}
