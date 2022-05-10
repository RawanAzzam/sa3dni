import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:sa3dni_app/patient/bookAppointment.dart';
import 'package:sa3dni_app/patient/contactWithOrganization.dart';
import 'package:sa3dni_app/patient/feedbackList.dart';
import 'package:sa3dni_app/patient/showEvents.dart';
import 'package:sa3dni_app/services/DatabaseServiceOrga.dart';
import 'package:sa3dni_app/services/databaseServicesNotification.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/shared/inputField.dart';
import '../models/category.dart';
import '../models/request.dart';
import '../services/databaseServicesRequests.dart';
import 'package:fluttertoast/fluttertoast.dart';
// ignore: must_be_immutable
class ViewOrganizationProfile extends StatefulWidget {
  Organization organization;
  String status;
  ViewOrganizationProfile(
      {Key? key, required this.organization, required this.status})
      : super(key: key);

  @override
  _ViewOrganizationProfileState createState() =>
      _ViewOrganizationProfileState();
}

class _ViewOrganizationProfileState extends State<ViewOrganizationProfile> {
  int eventCount = 0;
  final currentUser = FirebaseAuth.instance.currentUser;
  Patient? patient;
  List<Request> requests = [];
  List<Request> followers = [];

  int countFeedback = 0;
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

    FirebaseFirestore.instance
        .collection('events')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["organizationID"].toString().contains(widget.organization.id)) {
          setState(() {
            eventCount++;
          });
        }
      }
    });
    changeStatus();

    FirebaseFirestore.instance
        .collection('requests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if(doc['organizationID'].toString().contains(widget.organization.id)
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
    FirebaseFirestore.instance
        .collection('rates')
        .doc(widget.organization.id)
        .collection('organizationRates')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        setState(() {
          widget.organization.setRate(doc['rate']);
          countFeedback++;
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.organization.image),
                  radius: 60,
                ),
                const SizedBox(width: 20,),
                Column(
                  children: [
                    Text(
                      widget.organization.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Text(
                          "Category :",
                          style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.organization.category.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue[900],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(widget.organization.address)
                      ],
                    ),

                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                FlatButton.icon(
                    onPressed: () async {
                      if (getStatus(widget.organization.id)
                          .contains('nothing') ||
                          getStatus(widget.organization.id)
                              .contains('rejected')) {
                         await DatabaseServicesRequests()
                            .addRequest(
                            currentUser!.uid, widget.organization.id);

                       await  DatabaseServiceNotification()
                             .addConnectionRequestNotify(patient!, widget.organization.id);
                         changeStatus();

                      } else if (getStatus(widget.organization.id)
                          .contains('waiting') ||
                          getStatus(widget.organization.id)
                              .contains('accepted')) {
                     await DatabaseServicesRequests()
                            .deleteRequest(getId(widget.organization.id));


                       await  DatabaseServiceNotification()
                             .removeConnectionRequest(patient!.id,widget.organization.id);
                         changeStatus();
                       }

                    },
                    icon: Icon(
                      getStatus(widget.organization.id).contains('waiting')
                          ? Icons.cancel
                          : getStatus(widget.organization.id)
                          .contains('accepted')
                          ? Icons.person
                          : Icons.group_add,
                      color: Colors.blue,
                    ),
                    label: Text(getStatus(widget.organization.id)
                        .contains('waiting')
                        ? 'cancel'
                        : getStatus(widget.organization.id)
                        .contains('accepted')
                        ? 'Following'
                        : 'request')),
                const SizedBox(width: 20,),
                GestureDetector(
                  child: Row(
                    children: [
                      Text(
                        eventCount.toString(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)
                      ),
                      const Text(
                        "  Events",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),


                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowEvents(
                              id: widget.organization.id,
                            )));
                  },
                ),
                const SizedBox(width: 30,),
                Row(
                  children: [
                    Text(
                        followers.isNotEmpty ? followers.length.toString() : '0',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500)
                    ),
                    const Text(
                      "  Followers",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),


                  ],
                ),
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                FlatButton.icon(
                  icon: const Icon(
                    Icons.post_add_outlined,
                    color: Colors.purple,
                  ),
                  label: const Text('Book Appointment'),
                  onPressed: () {
                    if(  getStatus(widget.organization.id)
                        .contains('accepted')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookAppointment(
                              organizationId: widget.organization.id,
                              organizationName: widget.organization.name,
                              patient: patient!,
                            )));

                    }else{
                      Fluttertoast.showToast(
                          msg: "You Can Not Book Appointment if you are not following Organization",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                ),
                const SizedBox(width: 10,),
                FlatButton.icon(
                  icon: const Icon(
                    Icons.contact_support_outlined,
                    color: Colors.grey,
                  ),
                  label: const Text('Contact'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  ContactWithOrganization(organization: widget.organization,)));
                  },
                ),
              ],
            ),
            Divider(
              height: 50,
              color: ConstData().basicColor,
              indent: 20,
              endIndent: 20,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.organization.getRate().toString(),
                  style: const TextStyle(fontSize: 25),
                ),
                const SizedBox(
                  width: 15,
                ),
                RatingBar.builder(
                  ignoreGestures: true,
                  itemSize: 25,
                  initialRating: widget.organization.getRate(),
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
            const SizedBox(
              height: 15,
            ),
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
                          id: widget.organization.id,
                        )));
              },
            ),
            const SizedBox(
              height: 15,
            ),
            GestureDetector(child: const Text('Review'),
                onTap: (){
                  showModalBottomSheet(context: context, builder: (context){
                    return setReview();
                  }        );
                }),
          ],
        ),
      ),
    );
  }
  int rate = 0;
  String feedback = '';
  Widget setReview(){

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
      child: Column(

        children: [
          RatingBar.builder(
            itemSize: 30,
            initialRating: 0,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: false,
    itemCount: 5,
    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, _) => const Icon(
    Icons.star,
    color: Colors.amber,
    ),
    onRatingUpdate: (rating) {
    rate = rating.toInt();
    },
    ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: TextField(
              decoration: textInputField.copyWith(hintText: 'Enter Your Feedback'),
              minLines: 3,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: (e){
                feedback =e;
                print(e);
              },
            ),
          ),
          const SizedBox(height: 20),
          RaisedButton(
            onPressed: () async{
              print('Rate: '+rate.toString());
              DatabaseServiceOrga().addRate(
                  widget.organization,
                  rate,
                  feedback,
                  currentUser!.uid);
              widget.organization.listOfRate = [];
          await  FirebaseFirestore.instance
                  .collection('rates')
                  .doc(widget.organization.id)
                  .collection('organizationRates')
                  .get()
                  .then((QuerySnapshot querySnapshot) {
                for (var doc in querySnapshot.docs) {
                  setState(() {
                    widget.organization.setRate(doc['rate']);
                  });
                }
              });
              await DatabaseServiceOrga().
              updateInfo(widget.organization);
              Navigator.pop(context);
            },
          child: const Text('Review'),
          color: ConstData().secColor,)
        ],
      ));
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
  String getStatus(String organizationId) {
    for (var request in requests) {
      if (request.patientId == currentUser!.uid &&
          request.organizationId == organizationId) {
        return request.status;
      }
    }
    return 'nothing';
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
