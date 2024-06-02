

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfe2024/src/admin/homeA.dart';

//import 'package:pfe2024/src/admin/homeA.dart';

import 'package:pfe2024/src/home/home.dart';
import 'package:pfe2024/src/home/screens/home.dart';
import 'package:pfe2024/src/resturant/homeR.dart';




class verfiyEmail extends StatefulWidget {
  const verfiyEmail({super.key});

  @override
  State<verfiyEmail> createState() => _verfiyEmailState();
}

class _verfiyEmailState extends State<verfiyEmail> {
  bool isEmailVerified = false;
  bool canResend = false;
  Timer? time;
  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerficationEmail();
      time = Timer.periodic(Duration(seconds: 3), (timer) {
        checkEmailVerified();
      });
    }
  }

  @override
  void dispose() {
    time?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    var user = FirebaseAuth.instance.currentUser!;
    if (user.emailVerified) {
      time?.cancel();
      setState(() {
        isEmailVerified = true;
      });
    }
  }

  Future sendVerficationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() {
        canResend = false;
      });
      await Future.delayed(Duration(seconds: 5));
      setState(() {
        canResend = true;
      });
    } on Exception catch (e) {
      // TODO
      const SnackBar(content: Text("Failed to send verification email"));
    }
  }

  Widget verfiyRole() {
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!.data() as Map;
          final role = data['part'] as String;
          if (role == 'admin') {
            return MyAppAdmin();
          } else if (role == 'restaurant') {
            return MyHomeResto();
          } else {
            
            return Home();
          }
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? verfiyRole()
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "Email Verification",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              backgroundColor: Colors.blue[900],
              centerTitle: true,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    height: 300,
                    child: Image.asset(
                      "assests/logo.jpeg",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(25),
                  child: Text(
                      "An Email has been sent to your email address please verify your email",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                ),
                ElevatedButton(
                  onPressed: () {
                    canResend ? sendVerficationEmail() : null;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                    shadowColor: Colors.grey,
                  ),
                  child: Text("Resend Verification Email"),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.currentUser!.delete();
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .delete();
                    FirebaseAuth.instance.signOut();
                  },
                  child: Text(" Cancel  "),
                ),
              ],
            ),
          );
  }
}
