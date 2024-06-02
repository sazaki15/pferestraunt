import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pfe2024/src/resturant/form.dart';

import 'package:pfe2024/src/resturant/result.dart';


import 'package:cloud_firestore/cloud_firestore.dart';



class MyHomeResto extends StatelessWidget {
   var collection = FirebaseFirestore.instance.collection("users");
  
  final id = FirebaseAuth.instance.currentUser!.uid;

  Future<bool> isClientAdminG(String uid) async {
    DocumentSnapshot clientDoc = await collection.doc(uid).get();
    Map<String, dynamic>? clientData = clientDoc.data() as Map<String, dynamic>?;
    if (clientDoc.exists && clientData != null && clientData['part'] == "AdminG") {
      return true;
    } else {
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Ouvrir le menu
            _showMenu(context);
          },
        ),
        title: Text('Home' , style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        
      ),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      SizedBox(height: 20),
      Expanded(
        child: FutureBuilder<bool>(
          future: isClientAdminG(id),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(2, (index) => ServiceCard(index: index))
                );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              // While waiting for the future to complete, you can show a loader or any placeholder
              return Center(child: CircularProgressIndicator());
            } else {
              // Handle any other state, like error
              return Center(child: Text('Error occurred'));
            }
          },
        ),
      ),
    ],
  ),
)

    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Action pour éditer le profil
                FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class ServiceCard extends StatelessWidget {
  
  final int index;
  final List<Map<String, dynamic>> services = [
    {'Consultation': 'Add your Resturant' , 'icon' : FontAwesomeIcons.plus , 'page':AppointmentPage(id: '') },
    
    {'Consultation': 'Appointments' , 'icon' : FontAwesomeIcons.calendar , 'page': 
    ''},
    
  
   
  ];

  ServiceCard({required this.index});

 

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: services.length.toDouble(),
      shadowColor: Colors.blue.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: InkWell(
        onTap: () {
          // Action quand le cadre est cliqué
          
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => services[index]['page']),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon( services[index]['icon'] , size: 48, color: Colors.blue.shade900),
              SizedBox(height: 20),
              Text(services[index]['Consultation'], style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
