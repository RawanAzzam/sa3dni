import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/shared/constData.dart';

import '../models/category.dart';
import '../models/organization.dart';
class SearchOrganization extends StatefulWidget {
  const SearchOrganization({Key? key}) : super(key: key);

  @override
  _SearchOrganizationState createState() => _SearchOrganizationState();
}

class _SearchOrganizationState extends State<SearchOrganization> {

  List<Organization> organizations = <Organization>[];

  @override
  void initState() {
    super.initState();

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
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: ConstData().basicColor,
         ),
      body: Column(
        children: [
          ListTile(

          )
        ],
      ),
    );
  }
}
