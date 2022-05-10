import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/post.dart';

class DatabaseServicesPost{

  final collectionPosts = FirebaseFirestore.instance.collection('posts');

  Future addPost(Post post) async {
    try {
      return await collectionPosts.add({
        'organizationId':post.organizationId,
        'organizationName' :post.organizationName,
        'organizationImage':post.organizationImage,
        'content':post.content,
        'image':post.image,
        'time':post.time,
        'privacy':post.privacy,
      });
    } catch (e) {
      return null;
    }
  }

  Future updatePost(Post post,String id) async {
    try {
      return await collectionPosts.doc(id).update({
        'organizationId':post.organizationId,
        'organizationName' :post.organizationName,
        'organizationImage':post.organizationImage,
        'content':post.content,
        'image':post.image,
        'time':post.time,
        'privacy':post.privacy,
      });
    } catch (e) {
      return null;
    }
  }

  Future deletePost(String id) async {
    try {
      return await collectionPosts.doc(id).delete();
    } catch (e) {
      return null;
    }
  }



}