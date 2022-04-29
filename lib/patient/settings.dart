import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        title: const Text('Settings'),
      ),
      body: const Center(
        child: const Text("Settings"),
      ),
    );
  }
}
