import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/appointment.dart';
import 'package:intl/intl.dart';

class DatabaseServiceAppointment{

  final collectionAppointment = FirebaseFirestore.instance.collection('appointments');

  Future confirmAppointment(Appointment appointment) async{
    try{
   return await collectionAppointment
                .doc(appointment.docId)
                .update({
     'patientId':appointment.patientId,
     'patientName' : appointment.patientName,
     'phoneNumber':appointment.phoneNumber,
     'email':appointment.email,
     'category' : appointment.category.name,
     'status': appointment.status,
     'docId':appointment.docId,
     'date': DateFormat.yMd().format(appointment.date).toString(),
     'time':appointment.time.hour.toString()+":"+appointment.time.minute.toString(),
     'note':appointment.note
   });
    }catch(e){
      return null;
    }
  }

  Future bookAppointment(Appointment appointment ) async{
    try{
      return await  collectionAppointment.add({
        'patientId':appointment.patientId,
        'organizationId':appointment.organizationId,
        'organizationName':appointment.organizationName,
        'patientName' : appointment.patientName,
        'phoneNumber':appointment.phoneNumber,
        'email':appointment.email,
        'category' : appointment.category.name,
        'status': appointment.status
      }). then((value) async {
        await collectionAppointment
            .doc(value.id)
            .update({
          'patientId':appointment.patientId,
          'patientName' : appointment.patientName,
          'organizationId':appointment.organizationId,
          'organizationName':appointment.organizationName,
          'phoneNumber':appointment.phoneNumber,
          'email':appointment.email,
          'category' : appointment.category.name,
          'status': appointment.status,
          'docId':value.id
        });});
    }catch(e){
      print('hi');
      return null;
    }

  }


}