import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:pfe2024/src/resturant/formmodel.dart';
import 'package:pfe2024/src/resturant/info.dart';



class consultation_info extends StatefulWidget {
  const consultation_info({super.key});

  @override
  State<consultation_info> createState() => _consultation_infoState();
}

class _consultation_infoState extends State<consultation_info> {
  final List<Map<String,dynamic>> _all_clients = [];

  Future getFormId() async {
    if (_all_clients.isNotEmpty) {
      _all_clients.clear();
    }
    await FirebaseFirestore.instance
        .collection('Consultation')
        .get()
        .then((Snapshot) => Snapshot.docs.forEach((element) {
              _all_clients.add(element.data());
            }));
  }

// ignore: non_constant_identifier_names

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Consultation Info'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future: getFormId(),
                builder: (context, snapshot) {
                  if (_all_clients.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Consultation',
                        style: TextStyle(
                          color: Color.fromARGB(255, 170, 19, 19),
                          fontSize: 20,
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: _all_clients.length,
                        itemBuilder: (context, index) => Card(
                              key: ValueKey(_all_clients[index]),
                              color: Colors.blue[900],
                              elevation: 4,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 25),
                              child: ListTile(
                                
                                title: infoClients(
                                  id: _all_clients[index]['id'],
                                  isemail: true,
                                ),
                                subtitle: infoClients(
                                  id: _all_clients[index]['id'],
                                  isemail: false,
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.arrow_forward_ios , color: Colors.white,),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => show_consultation(
                                                id: _all_clients[index]['id'],
                                              )),
                                    );
                                  },
                                ),
                              ),
                            ));
                  }
                }),
          ),
        ],
      ),
    );
  }
}
