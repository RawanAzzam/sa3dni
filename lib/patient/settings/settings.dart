import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/patient/settings/personalInfoEditPatient.dart';
import 'package:sa3dni_app/patient/settings/privacyAndPolicyPatient.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

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
      body:ListView(
          children:[
            //// Personal Info
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
                    builder: (context) => const PersonalInfoEditPatient(),
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
                    builder: (context) => const PrivacyAndPolicyPatient(),
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
                  ),
                ),

                onTap: (){
                   openFile(
                       url:
                       'https://firebasestorage.googleapis.com/v0/b/sa3dni-b9d90.appspot.com/o/Patient%20Guide.pdf?alt=media&token=de363f86-2b31-465a-98be-651c522508a6',
                       fileName:
                       'patient_guide_book.pdf'
                   );
                },

              ),
            ),
          ]

      ),
    );
  }


}