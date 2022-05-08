import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/organization/eventPage.dart';
import 'package:sa3dni_app/shared/constData.dart';

class EventList extends StatefulWidget {
  String id;
   EventList({Key? key,required this.id}) : super(key: key);

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final currentUser = FirebaseAuth.instance.currentUser;
    @override
  Widget build(BuildContext context) {
           return Scaffold(
        appBar: AppBar(
          title: const Text('Events'),
          backgroundColor: ConstData().basicColor,
        ),
        body:  StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('events').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return  ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot userData =
                    snapshot.data!.docs[index];
                    String time = userData['time'].toString().substring(11, 15);
                    TimeOfDay timeOfDay =  TimeOfDay(
                        hour: int.parse(time.split(":")[0]),
                        minute: int.parse(time.split(":")[1]));
                    if(userData['organizationID'].toString().contains(currentUser!.uid)) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                        decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.all(Radius.circular(15)),
                        border:
                        Border.all(color: ConstData().basicColor, width: 1)),
                    child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                    children: [
                    Text(
                     userData['title'],
                    style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center,
                    ),
                    const Divider(
                    height: 25,
                    indent: 20,
                    endIndent: 20,
                    ),
                    Column(
                    children: [
                    Row(children: [
                    Icon(
                    Icons.date_range,
                    size: 20.0,
                    color: ConstData().basicColor,
                    ),
                    const SizedBox(
                    width: 15.0,
                    ),
                    Text(
                   userData['date'],
                    style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
                    )
                    ]),
                    const SizedBox(height: 15,),
                    Row(children: [
                    Icon(
                    Icons.access_time_outlined,
                    size: 20.0,
                    color: ConstData().basicColor,
                    ),
                    const SizedBox(
                    width: 15.0,
                    ),
                    Text(

                    MaterialLocalizations.of(context)
                        .formatTimeOfDay(timeOfDay),
                    style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
                    )
                    ]),
                    const SizedBox(height: 15,),
                    Row(children: [
                    Icon(
                    Icons.location_on,
                    size: 20.0,
                    color: ConstData().basicColor,
                    ),
                    const SizedBox(
                    width: 15.0,
                    ),
                    Text(
                    userData['location'],
                    style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
                    )
                    ]),
                    ],
                    ),
                    ],
                    ),
                    )));
                    }
                    else {
                      return  const Divider(height: 0,thickness: 0,);
                    }

                  }
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
          },
        ),


          floatingActionButton: FloatingActionButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const EventPage(),
                ));
              },
            backgroundColor: ConstData().basicColor,
            child: const Icon(Icons.add),
              ),
      );


  }

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
