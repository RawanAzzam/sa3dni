import 'package:sa3dni_app/chatscreens/ChatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:shimmer/shimmer.dart';
import '../models/category.dart';
import '../models/organization.dart';
import '../models/patient.dart';
import '../models/request.dart';

class ChattingScreen extends StatefulWidget {
  const ChattingScreen({Key? key}) : super(key: key);

  @override
  _ChattingScreenState createState() => _ChattingScreenState();
}

class _ChattingScreenState extends State<ChattingScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap ;
  Map<String, dynamic>? userMapSearch;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  Patient ? patient ;
  final currentUser = FirebaseAuth.instance.currentUser;
   List<Organization> organizations = <Organization>[];
  List<Request> requests = <Request>[];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["id"].toString().contains(currentUser!.uid)) {
          setState(() {
            patient = Patient(
                name: doc['name'] ,
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
            organizations = Organization(
                name: doc['name'],
                phoneNumber: doc['phoneNumber'],
                address: doc['address'],
                category: Category(name: doc['category']),
                email: doc['email'],
                id: doc['id'],
                image: doc['image']) as List<Organization>;
          });
        }
      }
    });

      FirebaseFirestore.instance
          .collection('requests')
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          if (doc['patientId'].toString().contains(currentUser!.uid) &&
              doc['status'].toString().contains('accepted')) {
            setState(() {
              requests.add(Request(organizationId: doc['organizationID'],
                  patientId: doc['patientId'],
                  status: doc['status'],
                  id: doc['id']));
              FirebaseFirestore.instance
                  .collection('organization')
                  .get()
                  .then((QuerySnapshot querySnapshot) {
                for (var doc in querySnapshot.docs) {
                  setState(() {
                    organizations.add(
                      // address , category , email , name , phoneNumber , rate
                        Organization(name: doc['name'],
                            phoneNumber: doc['phoneNumber'],
                            address: doc['address'],
                            category: Category(name: doc['category']),
                            email: doc['email'],
                            id: doc['id'],
                            image: doc['image']));
                  });
                }
              });
            });
          }
        }});


    // FirebaseFirestore.instance
    //     .collection('organization')
    //     .get()
    //     .then((value) {
    //   setState(() {
    //     userMap = value.docs[0].data();
    //     isLoading = false;
    //   });
    // });
  }
  Future<void> setusermap(String uid)async{

   await FirebaseFirestore.instance
       .collection('organization')
       .where('id', isEqualTo: uid)
       .get()
       .then((value) {
     setState(() {
       userMap = value.docs[0].data();
       isLoading = false;
     });
     // print(userMap);
   });


}

  String chatRoomId(String user1, String user2) {

     if (  user1.isNotEmpty &&
         (user1[0].toLowerCase().codeUnits[0]
             < user2.toLowerCase().codeUnits[0])) {
       return "$user1 send to $user2";
     }
     else
     {
       return "$user2 send to $user1";
     }
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('organization')
        .where('name', isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMapSearch = value.docs[0].data();
        isLoading = false;
      });
      // print(userMap);
    });
  }

  Organization? getOrganization(String id){

    for(var organization in organizations) {
      if(organization.id.contains(id)) {
        return organization;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    if(requests.isNotEmpty && organizations.isNotEmpty) {
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
      child : Column(
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
          userMapSearch != null
              ? ListTile(
            onTap: () {
              String roomId = chatRoomId(
                  patient!.id,
                  userMapSearch!['name']);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ChatRoom(
                        chatRoomId: roomId,
                        userMap: userMapSearch!,
                      ),
                ),
              );
            },
            leading: Icon(Icons.account_box, color: ConstData().basicColor),
            title: Text(
              userMapSearch!['name'],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(userMapSearch!['email']),
            trailing: Icon(Icons.chat, color: ConstData().basicColor),
          )
              : Container(
          ),
          const Divider(height: 20,
            color:Color(0xFFDAEFEF),
            endIndent: 15,
            indent: 15,
            thickness: 2,),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 10, 0.0),
              child:SingleChildScrollView(
              child: SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                getOrganization(requests[index].organizationId)!
                                    .image),
                          ),
                          const SizedBox(width: 10,),
                          TextButton(
                            onPressed: ()async {
                              // String name= await userMap!['name'];
                              await setusermap(requests[index].organizationId);
                              String roomId = chatRoomId(
                                patient!.id,
                                userMap!['name'],
                              );

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
                            Text(getOrganization(requests[index].organizationId)!
                                .name),

                          ),

                        ],
                      ),
                    );
                  },
                  // This next line does the trick.
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




