import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sa3dni_app/models/organization.dart';
import 'package:sa3dni_app/shared/constData.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ContactWithOrganization extends StatelessWidget {
  Organization organization;
  ContactWithOrganization({Key? key, required this.organization})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Contact'),
        backgroundColor: ConstData().basicColor,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 80, 0, 0),
        child: Column(
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 30, fontFamily: 'PermanentMarker'),
            ),
            SizedBox(
              height: 40,
            ),
            GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.call, color: Colors.green, size: 35),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(
                    width: 70,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Call',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'OpenSans')),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(organization.phoneNumber,
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500])),
                    ],
                  )
                ],
              ),
              onTap: () {
                _makePhoneCall(organization.phoneNumber);
              },
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.messenger,
                        color: Colors.lightBlue, size: 35),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(
                    width: 70,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SMS',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'OpenSans')),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(organization.phoneNumber,
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500])),
                    ],
                  )
                ],
              ),
              onTap: () {
                sendMessage(organization.phoneNumber);
              },
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.email, color: Colors.red, size: 35),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(
                    width: 70,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'OpenSans')),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(organization.email,
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500])),
                    ],
                  )
                ],
              ),
              onTap: () {
                sendEmail(organization.email);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> sendMessage(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(launchUri);
  }
}
