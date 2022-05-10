import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';
import '../models/ReportUser.dart';
import '../models/category.dart';
import '../models/organization.dart';
import '../models/patient.dart';
import 'package:shimmer/shimmer.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  const ChatRoom({Key? key, required this.chatRoomId, required this.userMap}) : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  Patient ? patient ;
  Organization? _organization ;


  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["id"].toString().contains(currentUser!.uid)) {
          setState(() {
            patient = Patient(
                name: doc['name'],
                email: doc['email'],
                category: Category(name: doc['category']),
                id: doc['id']);
          });
        }
      }
    });

    FirebaseFirestore.instance
        .collection('organization')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["id"].toString().contains(currentUser!.uid)) {
          setState(() {
            _organization = Organization(
                name: doc['name'],
                phoneNumber: doc['phoneNumber'],
                address: doc['address'],
                category: Category(name: doc['category']),
                email: doc['email'],
                id: doc['id'],
                image: doc['image']);
          });
        }
      }
    });
  }

  void onSendMessage() async {
    Map<String, dynamic>  messages={};
    if (_message.text.isNotEmpty) {
      if(currentUser!.uid==patient?.id){
        messages = {
          'id of sender':patient!.id,
          "send by ":  patient!.name,
          "id of receiver":widget.userMap['id'],
          'send to ': widget.userMap['name'],
          "message": _message.text,
          "type": "text",
          "time": FieldValue.serverTimestamp(),
        };

      }
      else if(currentUser!.uid==_organization?.id){
        messages = {
          'id of sender':_organization!.id,
          "send by ":  _organization!.name,
          "id of receiver":widget.userMap['id'],
          'send to ': widget.userMap['name'],
          "message": _message.text,
          "type": "text",
          "time": FieldValue.serverTimestamp(),
        };

      }

      _message.clear();
      await FirebaseFirestore.instance
          .collection('chatroom')
          .add(messages);

      }
    else {
      print("Enter Some Text");
    }


  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    if(currentUser!.uid==patient?.id ) {
      return map['type'] == "text"
          ? Container(
        width: size.width,
        alignment: map['id of sender'] == patient!.id
            // && map['id of receiver']==widget.userMap['id']
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: ConstData().basicColor,
          ),
          child: Text(
            map['message'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      )
          : Container(
        height: size.height / 2.5,
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        alignment: map['id of sender'] == patient!.id
            // && map['id of receiver']==widget.userMap['id']
            ? Alignment.centerRight
            : Alignment.centerLeft,
        // child: InkWell(
        //   onTap: () => Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (_) => ShowImage(
        //         imageUrl: map['message'],
        //       ),
        //     ),
        //   ),
        //   child: Container(
        //     height: size.height / 2.5,
        //     width: size.width / 2,
        //     decoration: BoxDecoration(border: Border.all()),
        //     alignment: map['message'] != "" ? null : Alignment.center,
        //     child: map['message'] != ""
        //         ? Image.network(
        //       map['message'],
        //       fit: BoxFit.cover,
        //     )
        //         : CircularProgressIndicator(),
        //   ),
        // ),
      );
    }
    else if (currentUser!.uid==_organization?.id ){
      return map['type'] == "text"
          ? Container(
        width: size.width,
        alignment: map['id of sender'] == _organization!.id
            // && map['id of receiver']==widget.userMap['id']
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: ConstData().basicColor,
          ),
          child: Text(
            map['message'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      )
          : Container(
        height: size.height / 2.5,
        width: size.width,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        alignment: map['id of sender'] == _organization!.id
            // && map['id of receiver']==widget.userMap['id']
            ? Alignment.centerRight
            : Alignment.centerLeft,
        // child: InkWell(
        //   onTap: () => Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (_) => ShowImage(
        //         imageUrl: map['message'],
        //       ),
        //     ),
        //   ),
        //   child: Container(
        //     height: size.height / 2.5,
        //     width: size.width / 2,
        //     decoration: BoxDecoration(border: Border.all()),
        //     alignment: map['message'] != "" ? null : Alignment.center,
        //     child: map['message'] != ""
        //         ? Image.network(
        //       map['message'],
        //       fit: BoxFit.cover,
        //     )
        //         : CircularProgressIndicator(),
        //   ),
        // ),
      );
    }
    else {
      return Container();
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if(currentUser!.uid==patient?.id){
      return Scaffold(
        appBar: AppBar(
          backgroundColor: ConstData().basicColor,
          title: StreamBuilder<DocumentSnapshot>(
            stream:
            FirebaseFirestore.instance
                .collection("organization")
                .doc(widget.userMap['uid']).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Column(
                  children: [
                    Text(widget.userMap['name']),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),

          actions: [
            FlatButton(
                onPressed:() {
                  showDialog(
                 context: context, builder: (context) => const ReportUser());

                },
                child: const Icon(Icons.report,color: Colors.white,)

            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: size.height / 1.25,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chatroom')
                     // .doc(widget.chatRoomId)
                     // .collection('chats')
                      .orderBy("time", descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          // if(map['id of sender'] == patient!.id && map['send to']==widget.userMap['name']) {
                            return messages(size, map, context);
                          // }
                          // else {
                          //   return Container();
                          // }

                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: SizedBox(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height / 17,
                        width: size.width / 1.3,
                        child: TextField(
                          controller: _message,
                          decoration: InputDecoration(
                            // suffixIcon: IconButton(
                            //   onPressed: () => getImage(),
                            //   icon: Icon(Icons.photo),
                            // ),
                              hintText: "Send Message",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.send), onPressed: onSendMessage),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    else if (currentUser!.uid==_organization?.id)  {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: ConstData().basicColor,
          title: StreamBuilder<DocumentSnapshot>(
            stream:
            FirebaseFirestore.instance.collection("organization")
                .doc(widget.userMap['uid']).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Container(
                  child: Column(
                    children: [
                      Text(widget.userMap['name']),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          actions: [
            FlatButton(
                onPressed:() {
                  showDialog(
                      context: context, builder: (context) => const ReportUser());
                },
                child: const Icon(Icons.report,color: Colors.white,)

            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height / 1.25,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream:  FirebaseFirestore.instance
                      .collection('chatroom')
                      // .doc(widget.chatRoomId)
                      // .collection('chats')
                      .orderBy("time", descending:false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {

                    if (snapshot.data != null) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          // if(map['id of sender'] == _organization!.id && map['send to']==widget.userMap['name']) {
                            return messages(size, map, context);
                          // }
                          // else {
                          //   return Container();
                          // }
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              Container(
                height: size.height / 10,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  height: size.height / 12,
                  width: size.width / 1.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: size.height / 17,
                        width: size.width / 1.3,
                        child: TextField(
                          controller: _message,
                          decoration: InputDecoration(
                            // suffixIcon: IconButton(
                            //   onPressed: () => getImage(),
                            //   icon: Icon(Icons.photo),
                            // ),
                              hintText: "Send Message",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              )),
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.send), onPressed: onSendMessage),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    else{
      return Scaffold(
        backgroundColor: Colors.white,
        body:  Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: ListView.builder(
                    itemBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 48.0,
                            height: 48.0,
                            color: Colors.white,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: 40.0,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    itemCount: 10,
                  ),
                ),
              )
            ],
          ),
        ),

      );
    }

  }


}