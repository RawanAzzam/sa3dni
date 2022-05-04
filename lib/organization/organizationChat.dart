import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chatscreens/OrganizationChatScreen.dart';

class OrganizationChat extends StatefulWidget {
  const OrganizationChat({Key? key}) : super(key: key);

  @override
  _OrganizationChatState createState() => _OrganizationChatState();
}

class _OrganizationChatState extends State<OrganizationChat> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {

    if (_auth.currentUser != null) {
      return const OrganizationChatScreen();

    } else {
      return const OrganizationChat();
    }

  }

}
