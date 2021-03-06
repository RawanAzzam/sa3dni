import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/appointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/services/databaseServiceAppointment.dart';
import 'package:sa3dni_app/services/databaseServicesNotification.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/patient.dart';
class AppointmentRequestList extends StatefulWidget {
  const AppointmentRequestList({Key? key}) : super(key: key);

  @override
  _AppointmentRequestListState createState() => _AppointmentRequestListState();
}

class _AppointmentRequestListState extends State<AppointmentRequestList> {
  final currentUser = FirebaseAuth.instance.currentUser;
  String note = '';
  var date = DateTime.now();
  var time = TimeOfDay.now();
  List<Patient> patients = <Patient>[];
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {

        setState(() {
          Patient patient =
          Patient(
              name: doc['name'],
              email: doc['email'],
              category:Category(name: doc['category']),
              id: doc['id']);
          patient.deviceToken = doc['deviceToken'];
          patients.add(patient);

        });

      }
    });
  }
  @override
  Widget build(BuildContext context) {
    int count = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
      ),
      body:StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance.collection('appointments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return  ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot userData =
                  snapshot.data!.docs[index];
                  if(userData['status'].toString().contains('waiting')
                     && userData['organizationId'].toString().contains(currentUser!.uid)){
                    count++;
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Image(image: NetworkImage('https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png')),
                            title: Text(userData['patientName']),
                            subtitle: Text("Category : "+userData['category']),
                          ),
                          const SizedBox(height: 15,),


                          FlatButton(onPressed: (){
                            Appointment appintment = Appointment.PatientInfo
                              (patientId: userData['patientId'],
                                organizationId: userData['organizationId'],
                                organizationName: userData['organizationName'],
                                phoneNumber: userData['phoneNumber'],
                                email: userData['email'],
                                patientName: userData['patientName'],
                                category: Category(name:userData['category']),
                                status: userData['status']);
                            showModalBottomSheet(context: context, builder: (context){
                              return selectDateAndTime(appintment,userData['docId']);
                            }        );
                          },
                            child: const Text('Confirm',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                            color: const Color(0xFFDAEFEF),
                            padding: const EdgeInsets.fromLTRB(80, 13, 80, 13),
                          ),
                          const Divider(height: 30,)

                        ],
                      ),
                    );
                  }else{
                    return const SizedBox();
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
    );
  }

  Widget selectDateAndTime(Appointment appointment,String docId){
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 0),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setSelectState) {
          return Column(
            children: [
              Row(children: [
                GestureDetector(
                  child: Icon(
                    Icons.date_range,
                    size: 30.0,
                    color: ConstData().basicColor,
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2050));
                    if (pickedDate != null && pickedDate != date) {
                      setSelectState(() {
                        date = pickedDate;
                      });
                    }
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
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null && pickedTime != date) {
                      setSelectState(() {
                        time = pickedTime;
                      });
                    }

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
                        hintText: "  Add Note",
                      ),
                      onChanged: (value) => {
                        setState((){
                          note = value;
                        })
                      },
                    ),
                  ),
                ),
              ]),
              const SizedBox(
                height: 30.0,
              ),
              RaisedButton(
                onPressed: () async{

                 Appointment appintment = Appointment(
                     patientId: appointment.patientId,
                     patientName: appointment.patientName,
                     email: appointment.email,
                     phoneNumber: appointment.phoneNumber,
                     organizationName: appointment.organizationName,
                     organizationId: appointment.organizationId,
                     category: appointment.category,
                     time: time,
                     date: date,
                     docId: docId,
                     status: 'confirm',
                     note: note);

                 await DatabaseServiceAppointment()
                 .confirmAppointment(appintment);

                await DatabaseServiceNotification()
                 .addAppointmentConfirmNotify(appointment,getDeviceToken(appintment.patientId)!);

                   Fluttertoast.showToast(
                       msg: "Appointment Confirmed Successfully",
                       toastLength: Toast.LENGTH_SHORT,
                       gravity: ToastGravity.BOTTOM,
                       backgroundColor: Colors.grey,
                       textColor: Colors.white,
                       fontSize: 16.0
                   );
                 Navigator.pop(context);


                },
                child: const Text('Confirm Appointment',
                    style: TextStyle(color: Colors.white)),
                color: ConstData().basicColor,)
            ],
          );
        }
      ),
    );
  }

  String? getDeviceToken(String id){
    for(Patient patient in patients) {
      if(patient.id == id) {
        return patient.deviceToken;
      }
    }
    return null;
  }

}
