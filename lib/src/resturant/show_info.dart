
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:pfe2024/src/resturant/form.dart';
import 'package:pfe2024/src/resturant/formmodel.dart';
import 'package:pfe2024/src/resturant/imagepage.dart';



// ignore: camel_case_types
class show_info extends StatefulWidget {
  final String id;
  show_info({Key? key, required this.id}) : super(key: key);

  @override
  _show_infoState createState() => _show_infoState(id: id);
}

class _show_infoState extends State<show_info> {
  final String id;
  _show_infoState({required this.id});
  Map<String, dynamic>? _clientData;

  Future<void> getInfo() async {
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(id)
        .get()
        .then((snapshot) {
          if (snapshot.exists) {
            _clientData = snapshot.data() as Map<String, dynamic>;
          }
        });
  }

  Widget infoCard(Map<String, dynamic> data) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            rowWidget(Icons.person, "Name", data['name']),
            rowWidget(Icons.location_on, "Address", data['address']),
            rowWidget(Icons.description, "Description", data['operation']),
            rowWidget(Icons.phone, "Phone", data['phone']),
            rowWidget(Icons.language, "Website", data['website']),
            rowWidget(Icons.access_time, "Hours", data['hours']),
            rowWidget(Icons.restaurant_menu, "Cuisine", data['cuisine']),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.image, color: Colors.blue[900]),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => imageview(images: data['images']),
                      ),
                    );
                  },
                  child: Text(
                    'Show Images',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget rowWidget(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[900]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: $value',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Restaurant Info'),
          centerTitle: true,
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Add your onPressed code here
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RestaurantForm(operation: '',
                        
                      )),
            );
          },
          child: const Icon(Icons.edit_calendar_sharp),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
              future: getInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  if (_clientData == null) {
                    return Center(
                      child: Text(
                        'No Clients',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    );
                  } else {
                    return infoCard(_clientData!);
                  }
                }
              }),
        ));
  }
}