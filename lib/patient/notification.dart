import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/models/notification.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sa3dni_app/patient/appointmentList.dart';
import 'package:sa3dni_app/patient/showEvents.dart';
import 'package:sa3dni_app/patient/showFollowing.dart';
import 'package:sa3dni_app/shared/constData.dart';

class NotificationPatient extends StatefulWidget {
  const NotificationPatient({Key? key}) : super(key: key);

  @override
  _NotificationPatientState createState() => _NotificationPatientState();
}

class _NotificationPatientState extends State<NotificationPatient> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<NotificationApp> notifications = <NotificationApp>[];
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('notifications')
        .doc('connectionAccept')
        .collection('notification')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['patientId'].toString().contains(currentUser!.uid)) {
          setState(() {
            Timestamp time = doc['time'];
            notifications.add(NotificationApp(
                message: doc['message'],
                time: time.toDate(),
                type: 'connection'));
          });
        }
      }
    });

    FirebaseFirestore.instance
        .collection('notifications')
        .doc('appointmentConfirm')
        .collection('notification')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['patientId'].toString().contains(currentUser!.uid)) {
          setState(() {
            Timestamp time = doc['time'];
            notifications.add(NotificationApp(
                message: doc['message'],
                time: time.toDate(),
                type: 'appointment'));
          });
        }
      }
    });

    FirebaseFirestore.instance
        .collection('notifications')
        .doc('patientEvent')
        .collection('notification')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['patientId'].toString().contains(currentUser!.uid)) {
          setState(() {
            Timestamp time = doc['time'];
            notifications.add(NotificationApp(
                message: doc['message'],
                time: time.toDate(),
                type: 'event'));
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: ConstData().basicColor,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
          child: Column(
            children: [
              notifications.isNotEmpty
                  ? getNotifications()
                  : SpinKitFadingCircle(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: index.isEven ? Colors.red : Colors.green,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ));
  }

  Widget getNotifications() {
    notifications.sort(
      (a, b) => b.time.compareTo(a.time),
    );
    return Flexible(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: ListTile(
                    leading: Icon(
                      notifications[index].type.contains('connection')
                          ? Icons.person
                          :  notifications[index].type.contains('event')?
                            Icons.event
                          : Icons.post_add_outlined,
                      color: notifications[index].type.contains('connection')
                          ? Colors.blue
                          : notifications[index].type.contains('event')?
                          Colors.red
                          : Colors.purple,
                    ),
                    title: Text(notifications[index].message),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            notifications[index].type.contains('connection')
                                ? const ShowFollowing()
                                : const AppointmentList(),
                      ));
                    },
                  ),
                ),
                const Divider(
                  height: 20,
                  indent: 30,
                  endIndent: 30,
                )
              ],
            );
          }),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
