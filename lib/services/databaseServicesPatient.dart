import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class DatabaseServicePatient{

  final patientCollection = FirebaseFirestore.instance.collection("patients");


  Future addPatient(Patient patient) async{
    return await FirebaseMessaging.instance.getToken().then((token) {
      patientCollection.doc(patient.id).set({
        'name':patient.name,
        'email':patient.email,
        "id" : patient.id,
        "category": patient.category.name,
        'image':'',
        'address':'',
        'phoneNumber':'',
        'contactPrivacy':false,
        'addressPrivacy':false,
        'level':'',
        'deviceToken': token
      });
    });

  }

  Future updatePatient(Patient patient) async{
    FirebaseMessaging.instance.getToken().then((token) {
      patientCollection.doc(patient.id).set({
        'name':patient.name,
        'email':patient.email,
        "id" : patient.id,
        "category": patient.category.name,
        'image':patient.image,
        'address':patient.address,
        'phoneNumber':patient.phoneNumber,
        'contactPrivacy':false,
        'addressPrivacy':false,
        'level':patient.level,
        'deviceToken': token
      });
    });

  }
  Future updatePatientPrivacy(Patient patient,bool contactPrivacy ,bool addressPrivacy ) async {

    FirebaseMessaging.instance.getToken().then((token) {
      patientCollection.doc(patient.id).set({
        'name': patient.name,
        'email': patient.email,
        "id": patient.id,
        "category": patient.category.name,
        'image': patient.image,
        'address': patient.address,
        'phoneNumber': patient.phoneNumber,
        'contactPrivacy': contactPrivacy,
        'addressPrivacy': addressPrivacy,
        'level':patient.level,
        'deviceToken': token
      });
    });

  }

  Future updateLevel(Patient patient) async {
    FirebaseMessaging.instance.getToken().then((token) {
      patientCollection.doc(patient.id).set({
        'name': patient.name,
        'email': patient.email,
        "id": patient.id,
        "category": patient.category.name,
        'image': patient.image,
        'address': patient.address,
        'phoneNumber': patient.phoneNumber,
        'contactPrivacy': patient.contactPrivacy,
        'addressPrivacy': patient.addressPrivacy,
        'level':patient.level,
        'deviceToken': token
      });
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