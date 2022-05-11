import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/patient/settings/personalInfoEditPatient.dart';
import 'package:sa3dni_app/patient/settings/privacyAndPolicyPatient.dart';
import 'package:sa3dni_app/shared/constData.dart';


class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool val1= true;
  bool val2= false;
  bool val3= false;

  onChangeFunction1(bool newValue1){
    setState((){
      val1= newValue1;
    });
  }

  onChangeFunction2(bool newValue2){
    setState((){
      val2= newValue2;
    });
  }

  onChangeFunction3(bool newValue3){
    setState((){
      val3= newValue3;
    });
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
            const SizedBox(height: 10,),
            Padding(
              padding:const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
              child: Row(
                children:  [
                const SizedBox(width: 10,),
                Icon(Icons.accessibility,color: ConstData().basicColor,),
                const SizedBox(width: 10,),
                const Text(
                  'Permissions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),)
              ],
            ),
      ),
            const Divider(height: 20,thickness: 2,),
            const SizedBox(height: 5,),
            Padding(
              padding:const EdgeInsets.symmetric(vertical: 1),
              child: Row(
              children:  [
                const SizedBox(width: 10,),
                const Icon(Icons.nightlight_round,color:Colors.amberAccent),
                const SizedBox(width: 10,),
                buildPermissionOption('Dark Mood           ', val1, onChangeFunction1)
              ],
            ),
            ),
            Padding(
              padding:const EdgeInsets.symmetric(vertical: 1),
              child:
            Row(
              children:  [
                const SizedBox(width: 10,),
                const Icon(Icons.notifications,color:Colors.black,),
                const SizedBox(width: 10,),
                buildPermissionOption('Push Notification', val2, onChangeFunction2),
              ],
            ),),
            Padding(
              padding:const EdgeInsets.symmetric(vertical: 1),
              child:
            Row(
              children:  [
                const SizedBox(width: 10,),
                const Icon(Icons.location_on,color: Colors.blue,),
                const SizedBox(width: 10,),
                buildPermissionOption('Access Location ', val3, onChangeFunction3),
              ],
            ),),
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
                  ),),

                onTap: (){

                },

              ),
            ),
          ]

      ),
    );
  }
  Padding buildPermissionOption(String title,bool value, Function onChangeMethod){
    return  Padding(
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
          const SizedBox(width: 80),
          Transform.scale(
            scale: 0.7,
            child:CupertinoSwitch(
              activeColor: ConstData().basicColor,
              trackColor: Colors.grey,
              value: value,
              onChanged: (bool newValue){
                onChangeMethod(newValue);
              },
            ) ,
          ),
        ],
      ),
    );
  }

}