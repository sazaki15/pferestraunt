
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:pfe2024/src/resturant/formmodel.dart';



// ignore: camel_case_types

class show_consultation extends StatefulWidget {
  final String id;
  show_consultation({super.key, required this.id});

  @override
  // ignore: no_logic_in_create_state
  State<show_consultation> createState() => _show_consultationState(id: id);
}

// ignore: camel_case_types
class _show_consultationState extends State<show_consultation> {
  final String id;
  _show_consultationState({required this.id});
  List<Map<String, dynamic>> images = [];
  List<Map<String, dynamic>> _all_clients = [];
  Future getInfo() async {
    if (_all_clients.isNotEmpty) {
      _all_clients.clear();
    }
    await FirebaseFirestore.instance
        .collection('Consultation')
        .doc(id)
        .collection('All_Consultation')
        .get()
        .then((Snapshot) => Snapshot.docs.forEach((element) {
              _all_clients.add(element.data());
            }));
  }

  // DataTable data(context) {
  //   return DataTable(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         boxShadow: const [
  //           BoxShadow(
  //             color: Colors.black12,
  //             blurRadius: 10,
  //             offset: Offset(0, 10),
  //           ),
  //         ],
  //         color: Colors.grey[100],
  //         border: Border.all(
  //           color: Colors.blue,
  //           width: 2,
  //         ),
  //       ),
  //       columns: [
  //         DataColumn(
  //             label: Text(
  //           'treatment',
  //           style: TextStyle(
  //               color: Colors.blue[900],
  //               fontWeight: FontWeight.bold,
  //               fontSize: 20),
  //         )),
  //         DataColumn(
  //             label: Text(
  //           'Name',
  //           style: TextStyle(
  //               color: Colors.blue[900],
  //               fontWeight: FontWeight.bold,
  //               fontSize: 20),
  //         )),
  //         DataColumn(
  //             label: Text(
  //           'phone',
  //           style: TextStyle(
  //               color: Colors.blue[900],
  //               fontWeight: FontWeight.bold,
  //               fontSize: 20),
  //         )),
  //         DataColumn(
  //             label: Text(
  //           'language',
  //           style: TextStyle(
  //               color: Colors.blue[900],
  //               fontWeight: FontWeight.bold,
  //               fontSize: 20),
  //         )),
  //       ],
  //       rows: _all_clients
  //           .map(
  //             (element) => DataRow(
  //               cells: [
  //                 DataCell(Text(
  //                   element['treatment'],
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //                 )),
  //                 DataCell(Text(
  //                   element['name'],
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //                 )),
  //                 DataCell(Text(
  //                   element['phone'],
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //                 )),
  //                 DataCell(Text(
  //                   element['language'],
  //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //                 )),
  //               ],
  //             ),
  //           )
  //           .toList());
  // }

  Widget consultationCard(Map<String, dynamic> data) {
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
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.blue[900]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Treatment: ${data['treatment']}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[900]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Name: ${data['name']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue[900]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Phone: ${data['phone']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.translate, color: Colors.blue[900]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Language: ${data['language']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: infoClients(id: id, isemail: true),
          centerTitle: true,
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
              future: getInfo(),
              builder: (context, snapshot) {
                if (_all_clients.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Clients',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: _all_clients
                        .map((clientData) => consultationCard(clientData))
                        .toList(),
                  );
                }
              }),
        ));
  }
}
