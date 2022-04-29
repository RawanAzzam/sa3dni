import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/models/patient.dart';

class DatabaseServicePatient{

  final patientCollection = FirebaseFirestore.instance.collection("patients");


  Future addPatient(Patient patient) async{
    return await patientCollection.add({
       'name':patient.name,
      'email':patient.email,
      "id" : patient.id,
      "category": patient.category.name
    });
  }

  Future<Patient?> getPatient(String id) async{
   await FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if(doc['id'].toString().contains(id)){
          print('Hi');
        return Patient(name: doc['name'],
                email: doc['email'],
                category: Category(name:doc['category']),
                id: doc['id']);
        }
      }
    });
    print('hello');
    return null;
  }





}