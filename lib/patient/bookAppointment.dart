import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/appointment.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sa3dni_app/shared/inputField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/services/databaseServiceAppointment.dart';
class BookAppointment extends StatefulWidget {
  String organizationId;
  String organizationName;
   BookAppointment({Key? key,required this.organizationId,
                              required this.organizationName}) : super(key: key);

  @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  String name = '';
  String email = '';
  String phoneNumber = '';
  String category = '';
  final currentUser = FirebaseAuth.instance.currentUser;

  final formKey = GlobalKey<FormState>();

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
               category = doc['category'];
             });
           }
         }
       });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("Book Appointment"),
        backgroundColor: ConstData().basicColor,
      ),
      backgroundColor: ConstData().secColor,
      body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.name,
                      decoration:
                          textInputField.copyWith(hintText: 'Enter Your Name'),
                      onChanged: (value) => {
                        setState(() {
                          name = value;
                        })
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration:
                      textInputField.copyWith(hintText: 'Enter Your PhoneNumber'),
                      onChanged: (value) => {
                        setState(() {
                          phoneNumber = value;
                        })
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                      textInputField.copyWith(hintText: 'Enter Your Email'),
                      onChanged: (value) => {
                        setState(() {
                          email = value;
                        })
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    RaisedButton(
                      onPressed: () async {

                        dynamic result = await DatabaseServiceAppointment()
                            .bookAppointment(Appointment.PatientInfo(
                                patientId: currentUser!.uid,
                                organizationId: widget.organizationId,
                                organizationName: widget.organizationName,
                                email: email,
                                patientName: name,
                                phoneNumber: phoneNumber,
                                category: Category(name: category),
                                status: 'waiting'  ));

                          Fluttertoast.showToast(
                              msg: "Appointment Request Booked Successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          formKey.currentState?.reset();

                      },
                      child: const Text('Book Appointment',
                          style: TextStyle(color: Colors.white)),
                      color: ConstData().basicColor,
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }


}
