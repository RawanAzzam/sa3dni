
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/organization/showFollowers.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/category.dart';
import '../models/request.dart';
import '../patient/feedbackList.dart';
import '../patient/showFollowing.dart';

class OrganizationProfile extends StatefulWidget {

  const OrganizationProfile({Key? key}) : super(key: key);

  @override
  State<OrganizationProfile> createState() => _OrganizationProfileState();
}

class _OrganizationProfileState extends State<OrganizationProfile> {
  Organization? _organization;

  double rate = 0.0;
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Request> followers = [];
  int eventCount = 0;
  int countFeedback = 0;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('rates')
        .doc(currentUser!.uid)
        .collection('organizationRates')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          countFeedback++;
        });
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
            rate = double.parse(doc['rate']);
          });
        }
      }
    });



    FirebaseFirestore.instance
        .collection('requests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if(doc['organizationID'].toString().contains(currentUser!.uid)
            && doc['status'].toString().contains('accepted')) {
          setState(() {
            followers.add(Request(organizationId: doc['organizationID'],
                patientId: doc['patientId'],
                status: doc['status'],
                id: doc['id']));
          });
        }
      }
    });


  }

  @override
  Widget build(BuildContext context) {

    if ( _organization != null) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Hi, ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                    ),
                  ),
                  Text(
                    _organization!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                        color: Colors.pink),
                  )
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(_organization!.image),
                radius: 60,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Category : ",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                  Text(_organization!.category.name,style: const TextStyle(fontSize: 15),),
                ],
              ),
              SizedBox(height: 20,),
              Row( mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Row(
                      children: [
                        Text(eventCount.toString(),style: const TextStyle(fontSize: 17),),
                        const Text("  Events",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),

                      ],
                    ),

SizedBox(width: 30,),
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(followers.length.toString(),style: const TextStyle(fontSize: 17),),
                        const Text("  Followers",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                      ],
                    ),
                    onTap: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const ShowFollowers()));

                    },
                  ),
                ],
              ),
              Divider(height: 50,color: ConstData().basicColor,indent: 20,endIndent: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rate.toString(),
                    style: const TextStyle(fontSize: 25),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  RatingBar.builder(
                    ignoreGestures: true,
                    itemSize: 25,
                    initialRating: rate,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20,),
              GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    const Icon(Icons.feedback_outlined,
                      color: Colors.green,),
                    const SizedBox(width: 20,),
                    Text(countFeedback.toString(),
                      style: const TextStyle(
                          fontFamily: 'DancingScript',
                          fontSize: 25
                      ),),
                    const Text('  Feedback',
                      style: TextStyle(
                        fontSize: 20,
                      ),),
                    const SizedBox(width: 20,),
                    const Icon(Icons.arrow_forward_ios_outlined,
                      size: 20,)
                  ],
                ),
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FeedbackList(
                            id: currentUser!.uid,
                          )));
                },
              ),



            ],
          ),
        ),
      );
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
                  style: TextStyle(fontSize: 18.0, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
