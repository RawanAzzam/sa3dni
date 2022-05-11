import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duration/duration.dart';
import 'package:shimmer/shimmer.dart';
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
