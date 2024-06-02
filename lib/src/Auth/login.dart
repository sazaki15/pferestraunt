import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:pfe2024/main.dart';

import 'package:pfe2024/src/Auth/forgetpass.dart';


class login extends StatefulWidget {
  final VoidCallback onSignedIn;
  const login({super.key, required this.onSignedIn});

  @override
  State<login> createState() => _loginState();
}

// ignore: camel_case_types
class _loginState extends State<login> {
  bool passToggle = true;
  String? erorMessage = "";
  bool isLogin = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            color: Colors.blue[900],
          ),
        );
      },
    );
    if (_emailController.text.trim() == "" ||
        _passwordController.text.trim() == "") {
      setState(() {
        erorMessage = "Please enter email and password";
        Navigator.pop(context);
      });
    } else {
      try {
        
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
         
        Navigator.pop(context);
        widget.onSignedIn();
         
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        _emailController.clear();
        _passwordController.clear();
        if (e.code == 'user-not-found') {
          setState(() {
            erorMessage = "No user found for that email";
          });
        } else if (e.code == 'wrong-password') {
          setState(() {
            erorMessage = "Wrong password provided for that user";
          });
        } else if (e.code == 'invalid-email') {
          setState(() {
            erorMessage = "Invalid Email";
          });
        } else {
          setState(() {
            erorMessage = "Something went wrong";
          });
        }
      }
    }
  }

  Widget title() {
    return Text(
      "Login",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            
            controller: isPassword ? _passwordController : _emailController,
            obscureText: isPassword ? passToggle : false,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              label: Text(title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusColor: Color.fromARGB(240, 13, 17, 55),
              fillColor: Color(0xfff3f3f4),
              filled: true,
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          passToggle = !passToggle;
                        });
                      },
                      icon: Icon(
                        passToggle ? Icons.visibility : Icons.visibility_off,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget forgetPassword() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Forget_password(),
            ),
          );
        },
        child: Text(
          "Forget Password?",
          style: TextStyle(
              color: Color.fromARGB(240, 201, 76, 74),
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _erorMessage() {
    if (erorMessage != "") {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        color: Colors.amberAccent,
        child: ListTile(
          title: Text(erorMessage!),
          leading: Icon(Icons.error),
          trailing: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                erorMessage = "";
              });
            },
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget submitButton() {
    return InkWell(
      onTap: () {
        signIn();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.shade200,
              offset: Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromRGBO(13, 71, 161, 1),
              Color.fromRGBO(13, 71, 161, 1),
            ],
          ),
        ),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        widget.onSignedIn();
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color.fromARGB(240, 201, 76, 74),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  //   Widget _signinWithgoogle() {
  //   return InkWell(
  //     onTap: () {
  //       AuthService().signInWithGoogle();
  //     },
  //     child:
  //       Container(
  //         margin: EdgeInsets.symmetric(vertical: 10),
  //         child: Column(
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.all(Radius.circular(20)),
  //                     boxShadow: <BoxShadow>[
  //                       BoxShadow(
  //                         color: Colors.grey.shade200,
  //                         offset: Offset(2, 4),
  //                         blurRadius: 5,
  //                         spreadRadius: 2,
  //                       ),
  //                     ],
  //                   ),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.all(Radius.circular(20)),
  //                     child: Image(
  //                       image: AssetImage("assests/images/google.png"),
  //                       height: 25,
  //                       width: 25,
  //                     ),
  //                     )
  //                   ),

  //                 SizedBox(
  //                   width: 10,
  //                 ),
  //                 Text(
  //                   'Sign in with Google',
  //                   style: TextStyle(
  //                       color: Color.fromRGBO(13, 71, 161, 1),
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),

  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 300,
                  child: Image.asset(
                    "assests/logo.jpeg",
                  ),
                ),
              ),
              _erorMessage(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _entryField("Email", isPassword: false),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _entryField("Password", isPassword: true),
              ),
              forgetPassword(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: submitButton(),
              ),
              SizedBox(height: 20),
              _divider(),
              _createAccountLabel(),
            ],
          ),
        ),
      ),
    );
  }
}
