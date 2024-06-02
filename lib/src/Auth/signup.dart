

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class signup extends StatefulWidget {
  final VoidCallback onSignedUp;
  const signup({super.key, required this.onSignedUp});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  bool passToggle = true;
  String? erorMessage = "";
  String? Reginphone = "+1";
  var collection = FirebaseFirestore.instance.collection("users");
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _confirmpasscontroller = TextEditingController();
  //final TextEditingController _rolecontroller = TextEditingController();
  final List<String> treatments = ['restaurant', 'client'];
  String? selectedTreatment;
  final _formKeyS = GlobalKey<FormState>();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future signup() async {
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
        _passwordController.text.trim() == "" ||
        _nameController.text.trim() == "" ||
        _phoneController.text.trim() == "" 
        ) {
      Navigator.pop(context);
      setState(() {
        erorMessage = "Please Fill all the fields";
        _emailController.clear();
        _passwordController.clear();
        _confirmpasscontroller.clear();
        _nameController.clear();
        _phoneController.clear();
        //_rolecontroller.clear();
      });
    } else if (!passconfirm()) {
      Navigator.pop(context);
      setState(() {
        erorMessage = "Password and Confirm Password are not same";
        _emailController.clear();
        _passwordController.clear();
        _confirmpasscontroller.clear();
        _nameController.clear();
        _phoneController.clear();
        //_rolecontroller.clear();
      });
    } else {
      // create user

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim())
          .catchError((error) {
        Navigator.pop(context);
        setState(() {
          erorMessage = error.message;
          _emailController.clear();
          _passwordController.clear();
          _confirmpasscontroller.clear();
          _nameController.clear();
          _phoneController.clear();
          //_rolecontroller.clear();
        });
      });
      Navigator.pop(context);
      // add user details to firestore
      adduser(
        userCredential,
        _nameController.text.trim(),
        _emailController.text.trim(),
        selectedTreatment!,
        int.parse(_phoneController.text.trim()),
      );
    }
  }

  Future adduser(UserCredential usercre, name, String email, String role,
      int phone) async {
    String finalphone = Reginphone! + phone.toString();
    String? token = await _firebaseMessaging.getToken();
    //await FirebaseApi().initNotifications();
    await collection.doc(usercre.user?.uid).set({
      "name": name,
      "email": email,
      "phone": finalphone,
      "part": role,
      'fcmtoken': token
    }).then((value) => {
          widget.onSignedUp(),
        });
  }

  Widget _erorMessage() {
    if (erorMessage != "") {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

  bool passconfirm() {
    if (_passwordController.text.trim() == _confirmpasscontroller.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  Widget title() {
    return Text(
      "Create Account",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _nameFiled(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            obscureText: isPassword,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value!.isEmpty) {
                return "Please Enter Name";
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: Text(title),
              focusColor: Color.fromRGBO(13, 71, 161, 1),
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneFiled(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntlPhoneField(
            controller: _phoneController,
            obscureText: isPassword,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || !value.isValidNumber()) {
                return "Please Enter Valid Phone Number";
              }
            },
            onCountryChanged: (country) {
              Reginphone = country.regionCode;
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: Text(title),
              focusColor: Color.fromRGBO(13, 71, 161, 1),
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailFiled(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            textInputAction: TextInputAction.next,
            controller: _emailController,
            obscureText: isPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please Enter Email";
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              label: Text(title),
              focusColor: Color.fromRGBO(13, 71, 161, 1),
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleFiled(String title, {bool isPassword = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField(
          value: selectedTreatment,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusColor: Color.fromRGBO(13, 71, 161, 1),
            fillColor: Color(0xfff3f3f4),
            filled: true,
          ),
          hint: Text('Select a treatment'),
          items: treatments.map((treatment) {
            return DropdownMenuItem(
              value: treatment,
              child: Text(treatment),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              selectedTreatment = val as String?;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please choose a treatment';
            }
            return null;
          },
        ),
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
            textInputAction: TextInputAction.next,
            controller:
                isPassword ? _passwordController : _confirmpasscontroller,
            obscureText: passToggle,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return isPassword
                    ? "Please Enter Password"
                    : "Please Enter Confirm Password";
              }
            },
            decoration: InputDecoration(
                label: Text(title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusColor: Color.fromRGBO(13, 71, 161, 1),
                fillColor: Color(0xfff3f3f4),
                filled: true,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      passToggle = !passToggle;
                    });
                  },
                  icon: Icon(
                    passToggle ? Icons.visibility : Icons.visibility_off,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        if (_formKeyS.currentState?.validate() ?? false) {
          signup();
        }
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
              const Color.fromRGBO(13, 71, 161, 1),
              const Color.fromRGBO(13, 71, 161, 1),
            ],
          ),
        ),
        child: Text(
          'Register Now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        widget.onSignedUp();
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
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

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmpasscontroller.dispose();
    //_rolecontroller.dispose();
    super.dispose();
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
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

  // Widget _sgininwithgoogle() {
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
          child: Form(
            key: _formKeyS,
            child: Column(
              children: [
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    height: 300,
                    child: Image.asset(
                      "assests/logo.jpeg",
                    ),
                  ),
                ),
                _erorMessage(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _nameFiled("Full Name"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _emailFiled("Email"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _phoneFiled("Phone Number"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _roleFiled("role"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _entryField("Password", isPassword: true),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _entryField("Confirm Password", isPassword: false),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _submitButton(),
                ),
                SizedBox(height: 10),
                _divider(),
                _loginAccountLabel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
