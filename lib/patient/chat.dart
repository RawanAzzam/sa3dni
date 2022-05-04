import 'package:flutter/material.dart';
import '../chatscreens/ChattingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {


  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser != null) {
      return const ChattingScreen();
    } else {
      return const ChatPage();
    }

  }

}
