import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sa3dni_app/models/event.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:sa3dni_app/services/databaseServiceEvent.dart';
import 'package:sa3dni_app/services/databaseServicesNotification.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/organization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String title = '';
  String location = '';
  String description = '';
  String privacy = 'public';
  var date = DateTime.now();
  var time = TimeOfDay.now();
  final formKey = GlobalKey<FormState>();
  final currentUser = FirebaseAuth.instance.currentUser!;
  Organization? organization;
  List<Patient> patients = <Patient>[];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('organization')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['id'].toString().contains(currentUser.uid)) {
          setState(() {
            organization = Organization(
                name: doc['name'],
                phoneNumber: doc['phoneNumber'],
                address: doc['address'],
                category: Category(name: doc['category']),
                email: doc['email'],
                id: doc['id'],
                image: doc['image']);
          });
        }
      }
    });

    getPatient();
  }

  void getPatient() {
    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {

          setState(() {
            Patient patient = Patient(
                name: doc['name'],
                email: doc['email'],
                category: Category(name: doc['category']),
                id: doc['id']);
            patient.address = doc['address'];
            patients.add(patient);
          });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
         return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        title: const Text('Add Event'),
      ),
      body:
      organization != null ?
      Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key:  formKey,
            child: ListView(
              children: [
                Column(
                  children: [
                     TextFormField(
                      decoration: const InputDecoration(
                        hintText: "  Add Title",
                      ),
                       onChanged: (value) => {
                         setState((){
                           title = value;
                         })
                       },
                                          ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(children: [
                      GestureDetector(
                        child: Icon(
                          Icons.date_range,
                          size: 30.0,
                          color: ConstData().basicColor,
                        ),
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                      Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey[300],
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            DateFormat.yMd().format(date).toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ))
                    ]),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Row(children: [
                      GestureDetector(
                        child: Icon(
                          Icons.access_time_outlined,
                          size: 30.0,
                          color: ConstData().basicColor,
                        ),
                        onTap: () {
                          _selectTime(context);
                        },
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                      Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey[300],
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Text(
                            MaterialLocalizations.of(context)
                                .formatTimeOfDay(time),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ))
                    ]),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 30.0,
                        color: ConstData().basicColor,
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                       Flexible(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: "  Add Location",
                            ),
                            onChanged: (value) => {
                              setState((){
                                location = value;
                              })
                            },
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          privacy.contains('public') ?
                          Icons.public:
                          Icons.person,
                          size: 30.0,
                          color: ConstData().basicColor,
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        DropdownButton<String>(
                          focusColor: Colors.grey[100],
                          value: privacy,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.grey,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              privacy = newValue!;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: <String>['public', organization != null ?
                          organization!.category.name
                              : 'your category']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(value,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),),
                              ),
                            );
                          }).toList(),
                        )],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Icon(
                        Icons.description,
                        size: 30.0,
                        color: ConstData().basicColor,
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                       Flexible(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
                          child: TextFormField(
                            decoration: const InputDecoration(
                              hintText: "  Add description",
                            ),
                            onChanged: (value) => {
                              setState((){
                                description = value;
                              })
                            },
                          ),
                        ),
                      ),
                    ]),
                   const SizedBox(height: 30,),
                    RaisedButton(
                      onPressed: () async{
                        OrganizationEvent event =
                        OrganizationEvent(
                            organizationID: FirebaseAuth.instance.currentUser!.uid,
                            organizationName: organization!.name,
                            category: organization!.category.name,
                            title: title,
                            date: date,
                            time: time,
                            location: location,
                            description: description);
                    var result =  await  DatabaseServiceEvent()
                        .addEvent(event);
                      if(result != null){
                        sendEventNotification(event, privacy);
                        Fluttertoast.showToast(
                            msg: "Event Added Successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                        formKey.currentState?.reset();
                      }
                      else{
                        Fluttertoast.showToast(
                            msg: "Something happened wrong",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      },
                      child: const Text('Add Event',
                          style: TextStyle(color: Colors.white)),
                      color: ConstData().basicColor,)
                  ],
                ),
              ],
            ),
          )) :
             SpinKitFadingCircle(
             itemBuilder: (BuildContext context, int index) {
           return DecoratedBox(
             decoration: BoxDecoration(
               color: index.isEven ? Colors.red : Colors.green,
             ),
           );
         },
    ),
    );



  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null && pickedDate != date) {
      setState(() {
        date = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != date) {
      setState(() {
        time = pickedTime;
      });
    }
  }


  void sendEventNotification(OrganizationEvent event,String privacy) async{
      for(Patient patient in patients) {
        if((privacy.contains('public') ||
            patient.category.name.contains(event.category)) &&
            patient.address.contains(event.location)){
          print('hi');
          await  DatabaseServiceNotification()
            .addPatientEventNotify(event, patient.id);
        }
      }
  }
}
