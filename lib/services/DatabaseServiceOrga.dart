import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sa3dni_app/models/category.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseServiceOrga {
  final collectionOrga = FirebaseFirestore.instance.collection('organization');
  final collectionRate = FirebaseFirestore.instance.collection('rates');


  Future addOrganization(
      Organization organization, String id, String image) async {
    try {
      return await collectionOrga.doc(id).set({
        'name': organization.name,
        'address': organization.address,
        'category': organization.category.name,
        'phoneNumber': organization.phoneNumber,
        'rate': organization.getRate().toString(),
        'id': organization.id,
        'image': image,
        'email': organization.email,
      });
    } catch (e) {
      return null;
    }
  }

  Future updateInfo(Organization organization) async {
    try {
      return await collectionOrga.doc(organization.id).set({
        'name': organization.name,
        'address': organization.address,
        'category': organization.category.name,
        'phoneNumber': organization.phoneNumber,
        'rate': organization.getRate().toString(),
        'id': organization.id,
        'image': organization.image,
        'email': organization.email,
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
