import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';


import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pfe2024/src/home/screens/text_widget.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<Profile> {
  final currentuser = FirebaseAuth.instance.currentUser;

  final auth = FirebaseAuth.instance;

  Future<void> changeEmail() async {
    String emailname = '';
    String password = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (val) {
                emailname = val;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'New Email',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              onChanged: (val) {
                password = val;
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            Text('Please enter your password to confirm changes')
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              var cred = EmailAuthProvider.credential(
                  email: currentuser!.email!, password: password);

              if (emailname.isNotEmpty) {
                try {
                  await currentuser!.reauthenticateWithCredential(cred);
                  await currentuser!.updateEmail(emailname);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentuser!.uid)
                      .update({
                    'email': emailname,
                  });
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Something went wrong'),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a value'),
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> editField(String field) async {
    String value = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          onChanged: (val) {
            value = val;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!value.isEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentuser!.uid)
                    .update({
                  field: value,
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a value'),
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> editphone() async {
    String value = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Phone'),
        content: IntlPhoneField(
          onChanged: (phone) {
            if (phone.isValidNumber()) {
              value = phone.completeNumber;
            }
            
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (!value.isEmpty) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentuser!.uid)
                    .update({
                  "phone": value,
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please a valid phone number'),
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentuser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: EdgeInsets.only(top: 120),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 32),
              physics: BouncingScrollPhysics(),
              children: [
                Icon(
                  Icons.person,
                  size: 100,
                  color: Colors.blue[900],
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'Name',
                  text: data['name'],
                  onPressed: () {
                    editField('name');
                  },
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'Email',
                  text: data['email'],
                  onPressed: () {
                    changeEmail();
                  },
                ),
                const SizedBox(height: 24),
                TextFieldWidget(
                  label: 'phone',
                  text: data['phone'],
                  onPressed: () {
                    editphone();
                  },
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text('Logout'),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    ));
  }
}
