import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';

class AppointmentList extends StatelessWidget {
  const AppointmentList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment'),
        backgroundColor: ConstData().basicColor,
      ),
    );
  }
}
