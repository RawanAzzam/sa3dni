import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/models/notification.dart';
import 'package:sa3dni_app/organization/appointmentRequestList.dart';
import 'package:sa3dni_app/organization/requestList.dart';
import 'package:sa3dni_app/shared/constData.dart';
class NotificationOrganization extends StatefulWidget {
  const NotificationOrganization({Key? key}) : super(key: key);

  @override
  _NotificationOrganizationState createState() => _NotificationOrganizationState();
}

class _NotificationOrganizationState extends State<NotificationOrganization> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<NotificationApp> notifications = <NotificationApp>[];
@override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('notifications')
        .doc('connectionRequest').
    collection('notification').
  get()
    .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['organizationId'].
        toString().contains(currentUser!.uid)) {
          setState(() {
           Timestamp time = doc['time'];
          notifications.add(
              NotificationApp(
                  message: doc['message'],
                  time: time.toDate(),
              type: 'connection'));
        });
        }
      }}
      );

    FirebaseFirestore.instance
        .collection('notifications')
        .doc('appointmentRequest').
    collection('notification').
    get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['organizationId'].
        toString().contains(currentUser!.uid)) {
          setState(() {
            Timestamp time = doc['time'];
            notifications.add(
                NotificationApp(
                    message: doc['message'],
                    time: time.toDate(),
                     type: 'appointment'));
          });
        }
      }}
    );
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
            notifications.isNotEmpty ? getNotifications()
                : SizedBox(),
          ],
        ),
      )
    );
  }

  Widget getNotifications(){
    notifications.sort((a, b) => b.time.compareTo(a.time),);
    return Flexible(
            child: ListView.builder(
              shrinkWrap: true,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                print(notifications.length);
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: ListTile(
                           leading:  Icon(
                             notifications[index].type.contains('connection') ?
                             Icons.group_add:Icons.post_add_outlined,
                           color:  notifications[index].type.contains('connection')?
                           Colors.blue : Colors.purple,),
                            title: Text(notifications[index].message),
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                notifications[index].type.contains('connection') ?
                                const RequestList() : const AppointmentRequestList(),
                              ));
                            },
                          ),
                        ),
                        const Divider(height: 20,
                          indent:30 ,endIndent: 30,)
                      ],
                    );
                  }

                ),
          );




  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
