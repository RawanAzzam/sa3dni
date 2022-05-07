import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category.dart';
import '../models/organization.dart';
import '../services/DatabaseServiceOrga.dart';
import '../shared/inputField.dart';
import 'package:sa3dni_app/services/uploadFile.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrganizationSetting extends StatefulWidget {
  const OrganizationSetting({Key? key}) : super(key: key);
  @override
  _OrganizationSettingState createState() => _OrganizationSettingState();
}

class _OrganizationSettingState extends State<OrganizationSetting> {
  bool val1= true;
  bool val2= false;
  bool val3= false;
  Organization? _organization;
  final currentUser = FirebaseAuth.instance.currentUser;
  UploadFile uploadFile = UploadFile();


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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        title: const Text('Settings'),
      ),
      body:Column(
        children: [
          ListView(
              shrinkWrap: true,
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
                      const Icon(Icons.notifications,color:Colors.black),
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
              ]

          ),

          //// Personal Info
          ListView(
              shrinkWrap: true,
              children:[
                const SizedBox(height: 10,),
                Padding(
                  padding:const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                  child: Row(
                    children:  [
                      const SizedBox(width: 10,),
                      Icon(Icons.info_outline,color: ConstData().basicColor,),
                      const SizedBox(width: 10,),
                      const Text(
                        'Personal Info',
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
                    child:
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                      title:    Text(_organization != null ?
                      _organization!.name : 'name'
                        ,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                      trailing: const Icon(Icons.mode_edit),
                      onTap: ()async{
                        await   showModalBottomSheet(context: context, builder: (context){
                          return showUpdateField('Name');

                        }        );
                        await DatabaseServiceOrga().updateInfo(updateName(dataChanged));
                        updateInfo();
                      },
                    )),
                Padding(
                    padding:const EdgeInsets.symmetric(vertical: 1),
                    child:
                    ListTile(
                      leading: CircleAvatar(backgroundImage:
                      NetworkImage(_organization != null ? _organization!.image:
                      'https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png'),),
                      title:    const Text('Your Photo'
                        ,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                      trailing: const Icon(Icons.photo_camera_outlined),
                      onTap: ()async{
                        await uploadFile.selectFile();
                        Fluttertoast.showToast(
                            msg: "please wait to upload image ...",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                        await uploadFile.uploadFile();

                        await DatabaseServiceOrga().
                        updateInfo(updateImage(uploadFile.getUriFile()));
                        updateInfo();
                      },
                    )),
                Padding(
                    padding:const EdgeInsets.symmetric(vertical: 1),
                    child: ListTile(
                      leading: const Icon(Icons.email,color: Colors.red,),
                      title:    Text(_organization != null ?_organization!.email : 'example@gmail.com'
                        ,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                      trailing: const Icon(Icons.mode_edit),
                      onTap: ()async{
                        await   showModalBottomSheet(context: context, builder: (context){
                          return showUpdateField('Email');

                        }        );
                        await DatabaseServiceOrga().updateInfo(updateEmail(dataChanged));
                        updateInfo();
                      },
                    )
                ),
                Padding(
                    padding:const EdgeInsets.symmetric(vertical: 1),
                    child:
                    ListTile(
                      leading: Icon(
                        Icons.phone,
                        color: Colors.green[800],
                      ),
                      title:    Text(_organization != null ?
                      _organization!.phoneNumber : '07788996521'
                        ,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                      trailing: const Icon(Icons.mode_edit),
                      onTap: ()async{
                        await   showModalBottomSheet(context: context, builder: (context){
                          return showUpdateField('Phone Number');

                        }        );
                        await DatabaseServiceOrga().
                        updateInfo(updatePhoneNumber(dataChanged));
                        updateInfo();
                      },
                    )),
                Padding(
                    padding:const EdgeInsets.symmetric(vertical: 1),
                    child:
                    ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Colors.blue[900],
                      ),
                      title:    Text(_organization != null ?
                      _organization!.address : 'Amman'
                        ,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                      trailing: const Icon(Icons.mode_edit),
                      onTap: ()async{
                        await   showModalBottomSheet(context: context, builder: (context){
                          return showUpdateField('Address');

                        }        );
                        await DatabaseServiceOrga().
                        updateInfo(updateAddress(dataChanged));
                        updateInfo();
                      },
                    )),
              ]

          ),
        ],
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

  String dataChanged = '';
  Widget showUpdateField(String hint){
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: Column(

          children: [

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: TextField(
                decoration: textInputField.copyWith(hintText: 'Enter Your $hint'),
                keyboardType: TextInputType.text,
                maxLines: null,
                onChanged: (e){
                  dataChanged = e;
                },
              ),
            ),
            const SizedBox(height: 20),
            RaisedButton(
              onPressed: () async{


                Navigator.pop(context);
              },
              child: const Text('Update'),
              color: ConstData().secColor,)
          ],
        ));
  }

  Organization updateEmail(String email){

    _organization!.email = email;
    return _organization!;
    /*await currentUser!.updateEmail('rawanazzam77@gmail.com');
    if(currentUser !=  null){
    currentUser!.reauthenticateWithCredential(
    EmailAuthProvider.credential(
    email: 'rawanazzam77@gmail.com',
    password: 'Rram1210!',
    ),
    );
    }else{
    print('null');

    }*/
  }

  Organization updateName(String name){
    _organization!.name = name;
    return _organization!;
  }
  Organization updatePhoneNumber(String phoneNumber){
    _organization!.phoneNumber = phoneNumber;
    return _organization!;
  }
  Organization updateAddress(String address){

    _organization!.address = address;
    return _organization!;
  }

  Organization updateImage(String image){
    _organization!.image = image;
    return _organization!;
  }
}