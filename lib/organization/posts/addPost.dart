import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/models/post.dart';
import 'package:sa3dni_app/services/databaseServicesPost.dart';
import 'package:sa3dni_app/services/uploadFile.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/category.dart';
import 'package:fluttertoast/fluttertoast.dart';
class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final currentUser = FirebaseAuth.instance.currentUser;
  UploadFile uploadFile = UploadFile();
  Organization? organization;
  String privacy  = 'public';
  String content = '';
  String image = '';
  final _keyForm = GlobalKey<FormState>();

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        title: const Text('Add Post'),
        actions: [
          FlatButton(
              onPressed: ()async{
                if(_keyForm.currentState!.validate() && organization != null){
                    Post post = Post(
                        organizationId: organization!.id,
                        organizationName: organization!.name,
                        organizationImage: organization!.image,
                        content: content,
                        image: image,
                        time: DateTime.now(),
                        privacy: privacy);
                   dynamic result = await DatabaseServicesPost().addPost(post);
                   if(result != null){
                     Fluttertoast.showToast(
                         msg: "Shared Post Successfully",
                         toastLength: Toast.LENGTH_SHORT,
                         gravity: ToastGravity.BOTTOM,
                         backgroundColor: Colors.grey,
                         textColor: Colors.white,
                         fontSize: 16.0
                     );
                     _keyForm.currentState!.reset();
                   }
                }

              },
              child:const Text('Share',
                style: TextStyle(color: Colors.grey),))
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 25, 20, 20),
        child: ListView(
          children: [
            Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      organization != null ?
                      organization!.image
                      : 'https://icons.iconarchive.com/icons/icons8/ios7/512/Users-User-Male-icon.png'

                    ),

                  ),
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(organization != null ? organization!.name : 'name',
                    style: const TextStyle(fontSize: 17,
                        fontWeight: FontWeight.w800),),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
                    child: DropdownButton<String>(
                      focusColor: Colors.grey[100],
                      value: privacy,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        ),
                      onChanged: (String? newValue) {
                        setState(() {
                          privacy = newValue!;
                        });
                      },
                      icon: const SizedBox(),
                      items: <String>['public', organization != null ?
                                                 organization!.category.name
                                                 : 'your category']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Text(value),
                              const SizedBox(width: 5,),
                              Icon(value.contains('public') ? Icons.public : Icons.group,
                              color: Colors.black,)
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Form(
                  key: _keyForm,
                  child: TextFormField(
                    validator: (value) =>
                    value.toString().isNotEmpty ? null : 'Post can not be empty',
                    decoration: InputDecoration(
                        hintText:  'Enter your post ... ',
                        filled: true,
                        fillColor: Colors.grey[100],
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white,width: 0)
                      ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white ,width: 0)
                        )
                    ),
                    minLines: 15,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onChanged: (e){
                     content = e;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar:  Padding(
        padding: const EdgeInsets.fromLTRB(0, 10 , 0, 20),
        child: ListTile(
          leading: image.isEmpty ?  const Icon(Icons.photo,color: Colors.green,) :
          Image(image: NetworkImage(image)),
          title: const Text('Add Photo'),
          trailing: const Icon(Icons.add),
          onTap: () async{
          await  uploadFile.selectFile();
          Fluttertoast.showToast(
              msg: "please wait to upload image ...",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.grey,
              textColor: Colors.white,
              fontSize: 16.0
          );
          await uploadFile.uploadFile();
          setState(() {
            image = uploadFile.getUriFile();
          });

          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
