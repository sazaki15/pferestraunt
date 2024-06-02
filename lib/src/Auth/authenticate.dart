
import 'package:pfe2024/src/Auth/verfiyEmail.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:pfe2024/src/Auth/wrapper.dart';





class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : StreamBuilder<User?> (
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.hasData ){
            
            return verfiyEmail();
          }
          else{
            return wrapper();
          }
        }
      ),
    );
  }
}