import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
class FeedbackList extends StatelessWidget {
  String id;
   FeedbackList({Key? key,required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
       title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: Column(
          children: [
            Image(image: NetworkImage('https://www.erdalozkaya.com/wp-content/uploads/2019/05/Feedback-1.jpg')),

            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream:  FirebaseFirestore.instance
                    .collection('rates')
                    .doc(id)
                    .collection('organizationRates')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return  ListView.builder(
                      shrinkWrap: true,
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot userData =
                          snapshot.data!.docs[index];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ListTile(
                                  title:  RatingBar.builder(
                                    ignoreGestures: true,
                                    itemSize: 25,
                                    initialRating: userData['rate'] * 1.0,
                                    minRating: 0,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ), onRatingUpdate: (double value) {  },
                                  ),
                                  leading:
                                  const CircleAvatar(backgroundImage:
                                  NetworkImage('https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png'),
                                  backgroundColor: Colors.white,
                                  radius: 30,
                                  ),
                                 subtitle: Padding(
                                   padding: const EdgeInsets.all(8.0),
                                   child: Text(userData['comment']),
                                 ),
                                )  ,


                              ),
                              Divider(height: 15,color: ConstData().basicColor,
                              endIndent: 40,indent: 40)
                            ],
                          );
                        }
                    );
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
            ),
          ],
        ),
      ),
    );
  }
}
