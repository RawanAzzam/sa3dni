import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/patient/bookAppointment.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/request.dart';
import '../organization/eventList.dart';
// ignore: must_be_immutable
class ViewOrganizationProfile extends StatefulWidget {
  Organization organization;
  String status;
   ViewOrganizationProfile({Key? key,required this.organization,required this.status}) : super(key: key);

  @override
  _ViewOrganizationProfileState createState() => _ViewOrganizationProfileState();
}

class _ViewOrganizationProfileState extends State<ViewOrganizationProfile> {
  int eventCount = 0;

  @override
  void initState() {

    super.initState();
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




  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: ConstData().basicColor,
      ) ,
      body:
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [

            const SizedBox(
              height: 25,
            ),
            CircleAvatar(
              backgroundImage: NetworkImage( widget.organization.image),
              radius: 60,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.organization.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          color: Colors.red[800],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text( widget.organization.email),

                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.green[800],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text( widget.organization.phoneNumber),

                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue[900],
                        ),
                        const SizedBox(width: 10,),
                        Text( widget.organization.address)
                      ],
                    ),

                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton.icon(
                    onPressed: () async {


                    },
                    icon:
                    Icon( widget.status.contains('waiting') ?
                    Icons.cancel : widget.status.contains('accepted') ?
                    Icons.person : Icons.group_add ,color: Colors.blue,),
                    label: Text( widget.status.contains('waiting') ?
                    'cancel' : widget.status.contains('accepted') ?
                    'Following' : 'request')),
                FlatButton.icon(
                  icon: const Icon(Icons.post_add_outlined,color: Colors.purple,),
                  label: const Text('Book Appointment'),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                       BookAppointment(organizationId: widget.organization.id,)));

                  },
                )
              ],
            ),
            Divider(height: 50,color: ConstData().basicColor,indent: 20,endIndent: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text("Rate",style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                    const SizedBox(height: 15,),
                    Text( widget.organization.getRate().toString(),style: const TextStyle(fontSize: 15),),
                  ],
                ),
                const SizedBox(width: 50,),
                Column(
                  children: [
                    const Text("Category",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                    const SizedBox(height: 15,),
                    Text( widget.organization.category.name,style: const TextStyle(fontSize: 15),),
                  ],
                ),
                const SizedBox(width: 50,),
                GestureDetector(
                  child: Column(
                    children: [
                      const Text("Events",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                      const SizedBox(height: 15,),
                      Text(eventCount.toString(),style: const TextStyle(fontSize: 15),),
                    ],
                  ),
                  onTap: (){
                   Navigator.push(context, MaterialPageRoute(builder: (context) =>  EventList(id: widget.organization.id,)));

                  },
                ),
              ],
            ),
            const SizedBox(height: 20,),


          ],
        ),
      ),
    );
  }

}
