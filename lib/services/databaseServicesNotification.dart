import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/appointment.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:intl/intl.dart';
class DatabaseServiceNotification {
  final collectionNotification = FirebaseFirestore.instance.collection('notifications');

 Future addConnectionRequestNotify(
      Patient patient,String organizationId) async {
    try {
      return await collectionNotification.doc('connectionRequest').
      collection('notification').doc(patient.id+organizationId).set({
        'organizationId':organizationId,
        'message' : patient.name + ' want to connect you in '+patient.category.name,
        'time':DateTime.now()
      });
    } catch (e) {
      return null;
    }
  }

  Future addConnectionAcceptNotify(
      Organization organization,String patientId) async {
    try {
      print(organization.name);
      print(organization.id);

      return await collectionNotification.doc('connectionAccept').
      collection('notification').doc(organization.id+patientId).set({
        'patientId':patientId,
        'message' : organization.name + ' accepted your request',
        'time':DateTime.now()
      });
    } catch (e) {
      return null;
    }
  }

  Future removeConnectionRequest(
      String patientId,String organizationId) async {
    try {
      return await collectionNotification.doc('connectionRequest').
      collection('notification').doc(patientId+organizationId).delete();

    } catch (e) {
      return null;
    }
  }

  Future addAppointmentRequestNotify(
      Patient patient,String organizationId,String name) async {
    try {
      return await collectionNotification.doc('appointmentRequest').
      collection('notification').add({
        'organizationId':organizationId,
        'message' : name + ' want to book appointment in category '+patient.category.name,
        'time':DateTime.now()
      });
    } catch (e) {
      return null;
    }
  }

  Future addAppointmentConfirmNotify(
      Appointment appointment) async {
    try {
      print('*******************************_________________');
      return await collectionNotification.doc('appointmentConfirm').
      collection('notification').add({
        'patientId':appointment.patientId,
        'message' : appointment.organizationName +
            ' confirm your book appointment in category '+
            appointment.category.name,
        'time':DateTime.now()
      });
    } catch (e) {
      return null;
    }
  }




}
