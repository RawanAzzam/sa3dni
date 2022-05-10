import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration/duration.dart';
class OrganizationPosts extends StatefulWidget {
  String category;
   OrganizationPosts({Key? key,
  required this.category}) : super(key: key);

  @override
  _OrganizationPostsState createState() => _OrganizationPostsState();
}

class _OrganizationPostsState extends State<OrganizationPosts> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot userData = snapshot.data!.docs[index];
                  if (userData['privacy']
                      .toString()
                      .contains(widget.category)
                     ||userData['privacy']
                          .toString()
                          .contains('public') ) {
                    Timestamp time = userData['time'];
                    return Container(
                      margin: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
                      decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              userData['organizationName'],
                              style: const TextStyle(
                                  fontSize: 16.0, fontFamily: 'DancingScript'),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Row(
                                children: [
                                  Text(
                                    showTime(time.toDate(), DateTime.now()) +
                                        ' ago',
                                    style: const TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: 'DancingScript'),
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Icon(
                                    userData['privacy'].contains('public')
                                        ? Icons.public
                                        : Icons.group,
                                    size: 14,
                                  )
                                ],
                              ),
                            ),
                            leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  userData['organizationImage'],
                                ),
                                backgroundColor: Colors.white),

                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Text(userData['content']),
                          ),
                          userData['image'].toString().isNotEmpty
                              ? Padding(
                            padding:
                            const EdgeInsets.fromLTRB(20, 5, 20, 10),
                            child: Image(
                              image: NetworkImage(
                                userData['image'],
                              ),
                              width: 400,
                              height: 400,
                            ),
                          )
                              : SizedBox(),
                          SizedBox(height: 10,)
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox(
                      height: 0,
                    );
                  }
                });
          } else {
            return Container(
              padding: const EdgeInsets.only(top: 30),
              child: Card(
                child: ListTile(
                  title: Column(
                    children: <Widget>[
                      Icon(
                        Icons.tag_faces,
                        color: Theme.of(context).primaryColor,
                        size: 35.0,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      const Text(
                        "No Record Found",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
  String showTime(DateTime postDate, DateTime nowDate) {
    final difference = nowDate.difference(postDate);

    if (difference.inSeconds < 60) {
      return difference.inSeconds.toString() + ' sec';
    } else if (difference.inSeconds >= 60 && difference.inMinutes < 60) {
      return difference.inMinutes.toString() + ' min';
    } else if (difference.inMinutes >= 60 && difference.inHours < 24) {
      return difference.inHours.toString() + ' h';
    } else if (difference.inHours >= 24 && difference.inDays < 7) {
      return difference.inDays.toString() + ' d';
    } else {
      return difference.inWeeks.toString() + ' w';
    }
  }
}
