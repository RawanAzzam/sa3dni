import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/post.dart';
import 'package:sa3dni_app/organization/posts/addPost.dart';
import 'package:duration/duration.dart';
import 'package:sa3dni_app/organization/posts/editPost.dart';
import 'package:sa3dni_app/services/databaseServicesPost.dart';
import '../../models/category.dart';
import '../../models/organization.dart';
import '../../shared/constData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostList extends StatefulWidget {
  const PostList({Key? key}) : super(key: key);

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final currentUser = FirebaseAuth.instance.currentUser;
  Organization? organization;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('organization')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc['id'].toString().contains(currentUser!.uid)) {
          setState(() {
            organization = Organization(
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddPost(),
          ));
        },
        backgroundColor: ConstData().basicColor,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                  if (userData['organizationId']
                      .toString()
                      .contains(currentUser!.uid)) {
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
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert_rounded),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text("Delete"),
                                  value: 1,
                                  onTap: () {},
                                ),
                                PopupMenuItem(
                                  child: const Text("Edit"),
                                  value: 2,
                                  onTap: () {
                                    print('hi');
                                  },
                                )
                              ],
                              onSelected: (value) {
                                if(value == 1){
                                  DatabaseServicesPost().deletePost(userData.id);
                                }
                                if (value == 2) {
                                  Post post = Post(
                                      organizationId:
                                          userData['organizationId'],
                                      organizationName:
                                          userData['organizationName'],
                                      organizationImage:
                                          userData['organizationImage'],
                                      content: userData['content'],
                                      image: userData['image'],
                                      time: time.toDate(),
                                      privacy: userData['privacy'],
                                      );
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        EditPost(post: post, id: userData.id),
                                  ));
                                }
                              },
                            ),
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
