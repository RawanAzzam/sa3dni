
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/appointment.dart';
import 'package:sa3dni_app/models/event.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:intl/intl.dart';
import 'package:sa3dni_app/services/pushNotifications.dart';
class DatabaseServiceNotification {
  final collectionNotification = FirebaseFirestore.instance.collection('notifications');
  PushNotifications pushNotifications = PushNotifications();
 Future addConnectionRequestNotify(
      Patient patient,String organizationId,String deviceToken) async {
    try {
      pushNotifications.sendPushMessage(deviceToken,
          patient.name + ' want to connect you in '+patient.category.name,
          'Connection Request');
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
      Organization organization,String patientId,String deviceToken) async {
    try {
       await collectionNotification.doc('connectionAccept').
      collection('notification').doc(organization.id+patientId).set({
        'patientId':patientId,
        'message' : organization.name + ' accepted your request',
        'time':DateTime.now()
      });
        pushNotifications.sendPushMessage(deviceToken,organization.name + ' accepted your request','Connection Request');
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
      Patient patient,Organization organization,String name) async {
    try {
      pushNotifications.sendPushMessage(organization.deviceToken,
          name + ' want to book appointment in category '+patient.category.name,
          'Appointment');
      return await collectionNotification.doc('appointmentRequest').
      collection('notification').add({
        'organizationId':organization.id,
        'message' : name + ' want to book appointment in category '+patient.category.name,
        'time':DateTime.now()
      });
    } catch (e) {
      return null;
    }
  }

  Future addAppointmentConfirmNotify(
      Appointment appointment,String deviceToken) async {
    try {
       await collectionNotification.doc('appointmentConfirm').
      collection('notification').add({
        'patientId':appointment.patientId,
        'message' : appointment.organizationName +
            ' confirm your book appointment in category '+
            appointment.category.name,
        'time':DateTime.now()
      });
       PushNotifications().sendPushMessage(deviceToken,
           appointment.organizationName +
               ' confirm your book appointment in category '+
               appointment.category.name,'Appointment');

    } catch (e) {
      return null;
    }
  }
  Future addPatientEventNotify(
     OrganizationEvent event,String patientId,String deviceToken) async {
    try {
       await collectionNotification.doc('patientEvent').
      collection('notification').add({
        'patientId':patientId,
        'message' : event.organizationName +
            ' invites you to attend his event about '+event.category,
        'time':DateTime.now()
      });
print(deviceToken);
       pushNotifications.sendPushMessage(deviceToken,
           event.organizationName +
               ' invites you to attend his event about '+event.category,
           'Event');
    } catch (e) {
      return null;
    }
  }



}
