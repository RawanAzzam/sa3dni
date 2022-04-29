import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/category.dart';

class Appointment{
  String patientId;
  late String organizationId;
  late String organizationName;
  String phoneNumber;
  String email;
  String patientName;
  late DateTime date;
  late TimeOfDay time;
  late Category category;
  late String docId;
  String status;

  Appointment(
  {
    required this.patientId,
    required this.patientName,
    required this.email,
    required this.phoneNumber,
    required this.organizationName,
    required this.organizationId,
    required this.category,
    required this.time,
    required this.date,
    required this.docId,
    required this.status
  }
      );

  Appointment.PatientInfo(
  {
    required this.patientId,
    required this.organizationId,
    required this.phoneNumber,
    required this.email,
    required this.patientName,
    required this.category,
    required this.status
   }
      );

}