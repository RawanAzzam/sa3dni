import 'package:flutter/material.dart';
import 'package:sa3dni_app/shared/constData.dart';
import '../../models/category.dart';
import '../../models/organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/DatabaseServiceOrga.dart';
import '../../services/uploadFile.dart';
import '../../shared/inputField.dart';
class PersonalInfoEditOrganization extends StatefulWidget {
  const PersonalInfoEditOrganization({Key? key}) : super(key: key);

  @override
  _PersonalInfoEditOrganizationState createState() => _PersonalInfoEditOrganizationState();
}

class _PersonalInfoEditOrganizationState extends State<PersonalInfoEditOrganization> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
        child: ListView(
          children: [
            Padding(
              padding:const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
              child: Row(
                children:  const [
                  SizedBox(width: 10,),
                  Icon(Icons.info_outline,color: Colors.black,),
                  SizedBox(width: 10,),
                  Text(
                    'Personal Info',
                    style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),)
                ],
              ),
            ),
            const Divider(height: 20,thickness: 2,),
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
                    _organization!.email = dataChanged;
                    await   showModalBottomSheet(context: context, builder: (context){
                      return showUpdateField('Password');

                    }        );
                    String password = dataChanged;
                    await currentUser!.updateEmail( _organization!.email);
                    if(currentUser !=  null){
                    await  currentUser!.reauthenticateWithCredential(
                        EmailAuthProvider.credential(
                          email:  _organization!.email,
                          password: password,
                        ),
                      );
                    }else{
                      print('null');

                    }
                    await DatabaseServiceOrga().updateInfo(_organization!);
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
          ],
        ),
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
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
