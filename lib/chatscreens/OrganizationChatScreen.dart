import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:shimmer/shimmer.dart';
import '../models/category.dart';
import '../models/patient.dart';
import '../models/request.dart';
import '../shared/constData.dart';
import 'ChatRoom.dart';


class OrganizationChatScreen extends StatefulWidget {
  const OrganizationChatScreen({Key? key}) : super(key: key);

  @override
  _OrganizationChatScreenState createState() => _OrganizationChatScreenState();
}

class _OrganizationChatScreenState extends State<OrganizationChatScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  Map<String, dynamic>? userMapsearch;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  Organization ? _organization ;
  List<Patient> patients = <Patient>[];
  List<Request> requests = <Request>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

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

    FirebaseFirestore.instance
        .collection('requests')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['organizationID'].toString().contains(currentUser!.uid) &&
            doc['status'].toString().contains('accepted')) {
          setState(() {
            requests.add(Request(organizationId: doc['organizationID'],
                patientId: doc['patientId'],
                status: doc['status'],
                id: doc['id']));
            FirebaseFirestore.instance
                .collection('patients')
                .get()
                .then((QuerySnapshot querySnapshot) {
              for (var doc in querySnapshot.docs) {
                setState(() {
                  patients.add(
                    // address , category , email , name , phoneNumber , rate
                      Patient(
                          name: doc['name'],
                          email: doc['email'],
                          category: Category(name:doc['category']),
                          id: doc['id']));
                });
              }
            });
          });
        }
      }});
  }


  String chatRoomId(String user1, String user2) {
    if (  user1.isNotEmpty &&
        (user1[0].toLowerCase().codeUnits[0]
            < user2.toLowerCase().codeUnits[0])) {
      return "$user2 send to $user1";
    } else {
      return "$user1 send to $user2";
    }
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });
      await FirebaseFirestore.instance
          .collection('patients')
          .where('name', isEqualTo: _search.text)
          .get()
          .then((value) {
        setState(() {
          userMapsearch = value.docs[0].data();
          isLoading = false;
        });
      });
  }

  Future<void> setusermap(String uid)async{

    await FirebaseFirestore.instance
        .collection('patients')
        .where('id', isEqualTo: uid)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
    });
  }

  Patient? getPatient(String id){
    for(var patient in patients) {
      if(patient.id.contains(id)) {
        return patient;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if(requests.isNotEmpty && patients.isNotEmpty) {
      return Scaffold(
        body: isLoading
            ? Center(
          child: SizedBox(
            height: size.height / 20,
            width: size.height / 20,
            child: const CircularProgressIndicator(),
          ),
        )
            : SingleChildScrollView(
          child :Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              height: size.height / 14,
              width: size.width,
              alignment: Alignment.center,
              child: SizedBox(
                height: size.height / 14,
                width: size.width / 1.15,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            ElevatedButton(
                onPressed: onSearch,
                child: const Text("Search"),
                style: ElevatedButton.styleFrom(
                  primary: ConstData().basicColor,)
            ),
            SizedBox(
              height: size.height / 30,
            ),
            userMapsearch != null
                ? ListTile(
              onTap: () {
                String roomId = chatRoomId(
                    _organization!.id,
                    userMapsearch!['name']);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ChatRoom(
                          chatRoomId: roomId,
                          userMap: userMapsearch!,
                        ),
                  ),
                );
              },
              leading: Icon(Icons.account_box, color: ConstData().basicColor),
              title: Text(
                userMapsearch!['name'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(userMapsearch!['email']),
              trailing: Icon(Icons.chat, color: ConstData().basicColor),
            )
                : Container(),
            const Divider(height: 20,
              color:Color(0xFFDAEFEF),
              endIndent: 15,
              indent: 15,
              thickness: 2,),
            // SingleChildScrollView(
             Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 10, 0.0),
                child:SingleChildScrollView(
                  child: SizedBox(
                  height: 400,
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context,index){
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundImage:
                              NetworkImage('https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png'),
                              radius: 25,
                              backgroundColor: Colors.white,
                            ),
                            const SizedBox(width: 10,),
                            TextButton(
                              onPressed: ()async {
                                await setusermap(requests[index].patientId);
                                String roomId = chatRoomId(
                                    _organization!.id,
                                    userMap!['name']);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChatRoom(
                                          chatRoomId: roomId,
                                          userMap: userMap!,
                                        ),
                                  ),
                                );
                              },
                              child:
                              Text(getPatient(requests[index].patientId)!.name),

                            ),
                          ],
                        ),
                      );
                    },
                    scrollDirection: Axis.vertical,

                  ),
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
                                )
                              ],
                            ),
                          ),
                          itemCount: 10,
                        ),
                      ),
                    ),

                  ],
                ),
              ),

            );
    }

  }
}
