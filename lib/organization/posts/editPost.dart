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
class EditPost extends StatefulWidget {
  Post post;
  String id;
   EditPost({Key? key,
     required this.post,
   required this.id}) : super(key: key);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  UploadFile uploadFile = UploadFile();


  final _keyForm = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ConstData().basicColor,
        title: const Text('Edit Post'),
        actions: [
          FlatButton(
              onPressed: ()async{
                if(_keyForm.currentState!.validate()){
                  Post post = Post(
                      organizationId: widget.post.organizationId,
                      organizationName:  widget.post.organizationName,
                      organizationImage:  widget.post.organizationImage,
                      content: widget.post.content,
                      image: widget.post.image,
                      time: widget.post.time,
                      privacy: widget.post.privacy,
                     );
                  dynamic result = await DatabaseServicesPost().updatePost(post,widget.id);

                    Fluttertoast.showToast(
                        msg: "Edit Post Successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                   Navigator.pop(context);

                }

              },
              child:const Text('Edit',
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
                        widget.post.organizationImage
                    ),

                  ),
                  title: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(widget.post.organizationName,
                      style: const TextStyle(fontSize: 17,
                          fontWeight: FontWeight.w800),),
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                    child: Row(
                      children: [
                        Icon(widget.post.privacy.contains('public') ?
                        Icons.public : Icons.group,
                          color: Colors.black,
                          size: 16,
                        ),
                      ],
                    )
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
                    initialValue: widget.post.content,
                    onChanged: (e){
                      widget.post.content = e;
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
          leading: widget.post.image.isEmpty ?  const Icon(Icons.photo,color: Colors.green,) :
          Image(image: NetworkImage(widget.post.image)),
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
              widget.post.image = uploadFile.getUriFile();
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
