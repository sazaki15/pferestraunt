import 'package:flutter/material.dart';
import 'package:pfe2024/src/Auth/signup.dart';

import 'login.dart';

class wrapper extends StatefulWidget {
  const wrapper({super.key});

  @override
  State<wrapper> createState() => _wrapperState();
}

class _wrapperState extends State<wrapper> {
  bool showLogin = true;
  void toggleView() {
    setState(() => showLogin = !showLogin);
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return login(onSignedIn:toggleView ,);
    } else {
      return signup(onSignedUp:toggleView ,);
    }
  }
}
