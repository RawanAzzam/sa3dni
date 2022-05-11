import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:sa3dni_app/services/databaseServicesPatient.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/category.dart';
class Quiz extends StatefulWidget {
  const Quiz({Key? key}) : super(key: key);

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  final currentUser = FirebaseAuth.instance.currentUser;
  Patient? _patient;
  List<bool> countCheck = [];
  int? countCheckNum = 0;


  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 50; i++) {
      countCheck.add(false);
    }
    FirebaseFirestore.instance
        .collection('patients')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc["id"].toString().contains(currentUser!.uid)) {
          setState(() {
            _patient = Patient(
                name: doc['name'],
                category: Category(name: doc['category']),
                email: doc['email'],
                id: doc['id']);
            _patient!.phoneNumber = doc['phoneNumber'];
            _patient!.image = doc['image'];
            _patient!.address = doc['address'];
            _patient!.contactPrivacy = doc['contactPrivacy'];
            _patient!.addressPrivacy = doc['addressPrivacy'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
      ),
      body: _patient != null ? Column(
        children: [
          Container(
            child: const Center(
                child: Text('Tick if you have any of these symptoms',
                style: TextStyle(
                  fontSize: 15
                ),)),
            color: Colors.white,
            height: 70,
            width: MediaQuery.of(context).size.width,
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quizzes')
                  .doc(_patient!.category.name)
                  .collection('questions')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  countCheckNum = snapshot.data?.docs.length.toInt();

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot userData = snapshot.data!.docs[index];
                        return Column(
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child: CheckboxListTile(
                                  value: countCheck[index],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      countCheck[index] = value!;
                                    });
                                  },
                                  title: Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Text(userData['question'],
                                        style: const TextStyle(fontSize: 14)),
                                  ),
                                  secondary: const Text(
                                    "?",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  checkColor: ConstData().basicColor,
                                  tileColor:
                                  index % 2 == 0 ?
                                  ConstData().secColor :
                                  Colors.white,
                                )),
                          ],
                        );
                      });
                } else {
                  return const LinearProgressIndicator();
                }
              },
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: Colors.white,
            child:  RaisedButton(
              onPressed: ()async {
                int count  = 0;
                for(bool flag in countCheck) {
                  if(flag) {
                    count++;
                  }
                }
                double percent = count * 1.0 / countCheckNum!;
                _patient!.level = (percent*100).toStringAsFixed(2)+'%';
                await DatabaseServicePatient().updateLevel(_patient!);
                Alert(context: context,
                   content:  CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 5.0,
                  percent:  percent,
                  center:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(percent <= 0.3 ? 'Low':
                                    percent > 0.3 && percent <= 0.65 ? 'Medium':
                                    'High'),
                      const SizedBox(height: 10),
                      Text((percent*100).toStringAsFixed(2)+'%')
                    ],
                  ),
                  progressColor: Colors.green,
                )).show();
                for (int i = 0; i < 50; i++) {
                  setState(() {
                    countCheck[i] = false;
                  });

                }
              },
              child: const Text('Done',
                  style: TextStyle(color: Colors.white)),
              color: ConstData().basicColor,),
          )
        ],
      ): SpinKitFadingCircle(
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven ? Colors.red : Colors.green,
            ),
          );
        },
      ),
    );
  }
}
