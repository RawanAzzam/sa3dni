import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/organization/Setting/personalInfo.dart';
import 'package:sa3dni_app/organization/Setting/privacyAndPolicy.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/category.dart';
import '../../models/organization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:sa3dni_app/services/uploadFile.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class OrganizationSetting extends StatefulWidget {
  const OrganizationSetting({Key? key}) : super(key: key);
  @override
  _OrganizationSettingState createState() => _OrganizationSettingState();
}

class _OrganizationSettingState extends State<OrganizationSetting> {
  Organization? _organization;
  final currentUser = FirebaseAuth.instance.currentUser;
  UploadFile uploadFile = UploadFile();

  @override
  void initState() {
    super.initState();

    updateInfo();
  }

  updateInfo(){
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

            _organization!.listOfRate = [];
            FirebaseFirestore.instance
                .collection('rates')
                .doc(_organization!.id)
                .collection('organizationRates')
                .get()
                .then((QuerySnapshot querySnapshot) {
              for (var doc in querySnapshot.docs) {
                setState(() {
                  _organization!.setRate(doc['rate']);
                });
              }
            });
          });
        }
      }
    });
  }

  Future openFile({required String url,String? fileName}) async{
    final file = await downloadFile(url, fileName!);

    if(file == null) return;
    print('Path :${file.path}');

    OpenFile.open(file.path);
  }

  Future<File?> downloadFile(String url,String name) async{
    try {
      final appStorge = await getApplicationDocumentsDirectory();
      final file = File('${appStorge.path}/$name');

      final response = await Dio().get(
        url,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0
        ),
      );

      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();

      return file;
    }catch(e){
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        title: const Text('Settings'),
      ),
      body:Column(
        children: [
          // Personal Info
          const SizedBox(height: 10,),
          Padding(
            padding:const EdgeInsets.symmetric(vertical: 1,horizontal: 5),
            child:ListTile(
              leading:Icon(Icons.info_outline,color: ConstData().basicColor,),
              title: const Text(
                'Personal Info',
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PersonalInfoEditOrganization(),
                ));
              },

            ),
          ),
          const SizedBox(height: 10,),
          Padding(
            padding:const EdgeInsets.symmetric(vertical: 1,horizontal: 5),
            child:ListTile(
              leading:Icon(Icons.local_police,color: ConstData().basicColor,),
              title: const Text(
                'Privacy & Policy',
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
              trailing: const Icon(Icons.arrow_forward_ios_outlined),
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PrivacyAndPolicyOrganization(),
                ));
              },

            ),
          ),
          const SizedBox(height: 10,),
          Padding(
            padding:const EdgeInsets.symmetric(vertical: 1,horizontal: 5),
            child:ListTile(
              leading:Icon(Icons.help,color: ConstData().basicColor,),
              title: const Text(
                'Help',
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),

              onTap: (){
                openFile(
                    url:'https://firebasestorage.googleapis.com/v0/b/sa3dni-b9d90.appspot.com/o/Organization%20Guide.pdf?alt=media&token=da13b519-fe4c-4c7b-922f-1dc14de4757d',
                    fileName:'organization_guide_book.pdf'
                );
              },
            ),
          ),
        ],
      ),
    );
  }



}