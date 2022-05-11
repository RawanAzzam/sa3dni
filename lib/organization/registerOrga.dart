import 'package:flutter/material.dart';
import 'package:sa3dni_app/homeWrapper.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/services/authenticateService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:sa3dni_app/wrapper.dart';
import '../models/person.dart';
import '../services/databaseServicePerson.dart';
import '../shared/inputField.dart';
import 'package:sa3dni_app/services/DatabaseServiceOrga.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sa3dni_app/services/uploadFile.dart';

class RegisterOrganization extends StatefulWidget {
  Category category;
   RegisterOrganization({Key? key,required this.category}) : super(key: key);

  @override
  _RegisterOrganizationState createState() => _RegisterOrganizationState();
}

class _RegisterOrganizationState extends State<RegisterOrganization> {

  final _keyForm = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String phoneNumber = '', name = '' ,  address = '';
  String image = 'https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png';
  final DatabaseServiceOrga _databaseServiceOrga =  DatabaseServiceOrga();
  UploadFile uploadFile = UploadFile();

  bool validateStructure(String value){
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[.!@#\$&*~]).{8,}$';
    RegExp regExp =  RegExp(pattern);
    return regExp.hasMatch(value);
  }
  @override
  void initState() {
    super.initState();
     }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Organization',style: TextStyle(color: Colors.white)),
        backgroundColor: ConstData().basicColor,
      ),
      backgroundColor: ConstData().secColor,
      body:  ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0,20.0,20.0,0.0),
              child:Form(
                  key: _keyForm,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 0.0),
                    child: Column(
                      children: [
                        GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(image),
                  radius: 35,
                  child: Icon(Icons.add_a_photo),
                ),
                onTap: () async{
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
                  setState(()  {
                    image = uploadFile.getUriFile();

                  });
                },
              ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                decoration: textInputField.copyWith(hintText: 'Full Name'),
                validator: (value) => value.toString().isNotEmpty ? null : 'Name Field can not be Empty ',
                keyboardType: TextInputType.text,
                onChanged: (value) => {
                  setState((){
                    name = value;
                  })
                },
              ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                decoration: textInputField.copyWith(hintText: 'Email'),
                validator: (value) => value.toString().isNotEmpty ? null : 'Email Field can not be Empty ',
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => {
                  setState((){
                    email = value;
                  })
                },
              ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                decoration: textInputField.copyWith(hintText: 'Phone Number'),
                validator: (value) => value.toString().length > 9 ? null : 'Phone Number is not correct',
                keyboardType: TextInputType.phone,
                onChanged: (value) => {
                  setState((){
                    phoneNumber = value;
                  })
                },
              ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                decoration: textInputField.copyWith(hintText: 'Password'),
                validator: (value) => validateStructure(value!) ? null :
                'password should be contains\n1 upper case \n'
                    '1 lowercase \n'
                    '1 Numeric Number \n'
                    '1 Special Character ',
                keyboardType: TextInputType.text,
                obscureText: true,
                onChanged: (value) => {
                  setState((){
                    password = value;
                  })
                },
              ),
                        const SizedBox(height: 10.0),
                        TextFormField(
                decoration: textInputField.copyWith(hintText: 'Address'),
                validator: (value) => value.toString().isNotEmpty ? null : 'Address can not be empty',
                keyboardType: TextInputType.streetAddress,
                onChanged: (value) => {
                  setState((){
                    address = value;
                  })
                },
              ),
                        const SizedBox(height: 20,),
                        RaisedButton(
                          onPressed: () async{
                            if(_keyForm.currentState!.validate()){
                              User? user = await  AuthenticateService().registerWithEmailAndPassword(email, password);
                              if(user != null){
                                Organization organization = Organization(name: name, phoneNumber: phoneNumber,
                               address: address, category: widget.category,email: email,id:user.uid,image: image);
                                dynamic finalUser =  await  DatabaseServicePerson().addUser(user, "organization");
                                dynamic data =  await  _databaseServiceOrga.addOrganization(organization,user.uid,image);
                           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper()));
                         }

                    }
                  },
              child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
                color: ConstData().basicColor,

              ),
                        const SizedBox(height: 15.0,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Have an account?  ',
                              style: TextStyle(color: Colors.black),),
                            GestureDetector(
                              child: Text('Sign in',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.underline,
                                  fontSize: 15,
                                ),
                              ),
                              onTap: (){
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
              ),
            ),
          ]
      ),
    );
  }
  }
