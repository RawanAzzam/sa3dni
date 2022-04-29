import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/appointment.dart';


class DatabaseServiceAppointment{

  final collectionAppointment = FirebaseFirestore.instance.collection('appointments');

  Future bookAppointment(Appointment appointment ) async{
    try{
      return await  collectionAppointment.add({
        'patientId':appointment.patientId,
        'organizationId':appointment.organizationId,
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