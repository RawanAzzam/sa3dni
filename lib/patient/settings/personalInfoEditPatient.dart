import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/patient.dart';
import 'package:sa3dni_app/services/databaseServicesPatient.dart';
import 'package:sa3dni_app/shared/constData.dart';
import '../../models/category.dart';
import '../../models/organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/DatabaseServiceOrga.dart';
import '../../services/uploadFile.dart';
import '../../shared/inputField.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class PersonalInfoEditPatient extends StatefulWidget {
  const PersonalInfoEditPatient({Key? key}) : super(key: key);

  @override
  _PersonalInfoEditPatientState createState() => _PersonalInfoEditPatientState();
}

class _PersonalInfoEditPatientState extends State<PersonalInfoEditPatient> {
  Patient? _patient;
  final currentUser = FirebaseAuth.instance.currentUser;
  UploadFile uploadFile = UploadFile();

  @override
  void initState() {
    super.initState();
    updateInfo();
  }
  updateInfo(){
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
            _patient!.addressPrivacy = doc['addressPrivacy'];
            _patient!.contactPrivacy = doc['contactPrivacy'];
            _patient!.level = doc['level'];

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
      body: _patient != null ? Padding(
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
                  title:    Text(_patient!.name
                    ,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                  trailing: const Icon(Icons.mode_edit),
                  onTap: ()async{
                    await   showModalBottomSheet(context: context, builder: (context){
                      return showUpdateField('Name');

                    }        );
                    if(dataChanged.isNotEmpty){
                      await DatabaseServicePatient().
                      updatePatient(updateName(dataChanged));
                      updateInfo();
                    }

                  },
                )),
            Padding(
                padding:const EdgeInsets.symmetric(vertical: 1),
                child:
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage:
                  NetworkImage(_patient!.image.isNotEmpty ? _patient!.image:
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

                    await DatabaseServicePatient().
                    updatePatient(updateImage(uploadFile.getUriFile()));
                    updateInfo();
                  },
                )),
            Padding(
                padding:const EdgeInsets.symmetric(vertical: 1),
                child: ListTile(
                  leading: const Icon(Icons.email,color: Colors.red,),
                  title:    Text(_patient!.email
                    ,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                  trailing: const Icon(Icons.mode_edit),
                  onTap: ()async{
                    await   showModalBottomSheet(context: context, builder: (context){
                      return showUpdateField('Email');

                    }        );
                    if(dataChanged.isNotEmpty){
                      _patient!.email = dataChanged;
                      await   showModalBottomSheet(context: context, builder: (context){
                        return showUpdateField('Password');

                      }        );
                      String password = dataChanged;
                      await currentUser!.updateEmail( _patient!.email);
                      if(currentUser !=  null){
                        await  currentUser!.reauthenticateWithCredential(
                          EmailAuthProvider.credential(
                            email:  _patient!.email,
                            password: password,
                          ),
                        );
                    }

                    }else{
                      print('null');

                    }
                    if(dataChanged.isNotEmpty){
                      await DatabaseServicePatient().updatePatient(_patient!);
                      updateInfo();
                    }

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
                  title:    Text(_patient!.phoneNumber.isNotEmpty ?
                  _patient!.phoneNumber : 'Add Your Phone Number'
                    ,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                  trailing: const Icon(Icons.mode_edit),
                  onTap: ()async{
                    await   showModalBottomSheet(context: context, builder: (context){
                      return showUpdateField('Phone Number');

                    }        );
                    if(dataChanged.isNotEmpty){
                      await DatabaseServicePatient().
                      updatePatient(updatePhoneNumber(dataChanged));
                      updateInfo();
                    }

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
                  title:    Text(_patient!.address.isNotEmpty ?
                  _patient!.address : 'Add Your Address'
                    ,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500),),
                  trailing: const Icon(Icons.mode_edit),
                  onTap: ()async{
                    await   showModalBottomSheet(context: context, builder: (context){
                      return showUpdateField('Address');

                    }        );
                    if(dataChanged.isNotEmpty){
                      await DatabaseServicePatient().
                      updatePatient(updateAddress(dataChanged));
                      updateInfo();
                    }

                  },
                )),
          ],
        ),
      ) :
      SpinKitFadingCircle(
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



  Patient updateName(String name){
    _patient!.name = name;
    return _patient!;
  }
  Patient updatePhoneNumber(String phoneNumber){
    _patient!.phoneNumber = phoneNumber;
    return _patient!;
  }
  Patient updateAddress(String address){

    _patient!.address = address;
    return _patient!;
  }

  Patient updateImage(String image){
    _patient!.image = image;
    return _patient!;
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
