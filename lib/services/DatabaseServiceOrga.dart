import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class DatabaseServiceOrga {
  final collectionOrga = FirebaseFirestore.instance.collection('organization');
  final collectionRate = FirebaseFirestore.instance.collection('rates');


  Future addOrganization(
      Organization organization, String id, String image) async {
    try {
      FirebaseMessaging.instance.getToken().then((token) {
        collectionOrga.doc(id).set({
          'name': organization.name,
          'address': organization.address,
          'category': organization.category.name,
          'phoneNumber': organization.phoneNumber,
          'rate': organization.getRate().toString(),
          'id': organization.id,
          'image': image,
          'email': organization.email,
        'deviceToken': token,
          'contactPrivacy':false
      });
    });

    } catch (e) {
      return null;
    }
  }

  Future updateInfo(Organization organization) async {
    try {
      return await  FirebaseMessaging.instance.getToken().then((token) {
        collectionOrga.doc(organization.id).set({
          'name': organization.name,
          'address': organization.address,
          'category': organization.category.name,
          'phoneNumber': organization.phoneNumber,
          'rate': organization.getRate().toString(),
          'id': organization.id,
          'image': organization.image,
          'email': organization.email,
          'deviceToken': token,
          'contactPrivacy':organization.contactPrivacy
        });
      });

    }
    catch (e) {
      print(e);
      return null;
    }
  }


  Future updatePrivacy(Organization organization,bool privacy) async {
    try {
      return await  FirebaseMessaging.instance.getToken().then((token) {
        collectionOrga.doc(organization.id).set({
          'name': organization.name,
          'address': organization.address,
          'category': organization.category.name,
          'phoneNumber': organization.phoneNumber,
          'rate': organization.getRate().toString(),
          'id': organization.id,
          'image': organization.image,
          'email': organization.email,
          'deviceToken': token,
          'contactPrivacy':privacy
        });
      });

    }
    catch (e) {
      print(e);
      return null;
    }
  }
  Future addRate(Organization organization, int rate,String feedback,
      String patientId) async {
    print("feedback"+feedback);
    return await collectionRate
        .doc(organization.id)
        .collection('organizationRates')
        .doc(patientId)
        .set({'rate': rate,
               'comment':feedback});

  }
}
