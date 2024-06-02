import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class infoClients extends StatelessWidget {
  final String id;
  final bool isemail;

  infoClients({required this.id, required this.isemail});

  @override
  Widget build(BuildContext context) {
    CollectionReference form = FirebaseFirestore.instance.collection('users');
    if (isemail) {
      return FutureBuilder<DocumentSnapshot>(
          future: form.doc(id).get(),
          builder: ((context, snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                data['email'].toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              );
            }

            return Text("loading");
          }));
    }else{
      return FutureBuilder<DocumentSnapshot>(
          future: form.doc(id).get(),
          builder: ((context, snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              return Text(
                data['phone'].toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              );
            }

            return Text("loading");
          }));
    }
  }
}
