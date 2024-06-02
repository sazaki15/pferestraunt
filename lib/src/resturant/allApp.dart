import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class AllAppointmentsPage extends StatefulWidget {
  @override
  _AllAppointmentsPageState createState() => _AllAppointmentsPageState();
}

class _AllAppointmentsPageState extends State<AllAppointmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('departureDate',
                isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
            .orderBy(
                'arrivalDate') // Orders them in ascending order by arrivalDate
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No appointments found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return AppointmentCard(
                data: snapshot.data!.docs[index],
                context: context,
              );
            },
          );
        },
      ),
    );
  }
}

Widget card(data) {
  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yy').format(dateTime);
  }

  return Card(
    elevation: 5,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoClients(
              id: data[
                  'id']), // This line fetches the email and places it at the top of the card
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Arrival Date: ${formatDate(data['arrivalDate'] as Timestamp)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Operation Date: ${formatDate(data['opDate'] as Timestamp)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Departure Date: ${formatDate(data['departureDate'] as Timestamp)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Procedure: ${data['procedureType']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Package Amount: \$${data['packageAmount']}',
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

Future<void> editField(String id, context) async {
  String value = '';
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Edit Note'),
      content: TextField(
        onChanged: (val) {
          value = val;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (!value.isEmpty) {
              await FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(id)
                  .update({
                'Note': value,
              });
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter a value'),
                ),
              );
            }
          },
          child: Text('Save'),
        ),
      ],
    ),
  );
}

Widget admincard(data, context) {
  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yy').format(dateTime);
  }

  return Card(
    elevation: 5,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoClients(
              id: data[
                  'id']), // This line fetches the email and places it at the top of the card
          SizedBox(height: 8),
          Row(
              children: [
                Icon(Icons.hotel, color: Colors.blue[900]),
                SizedBox(width: 8),
                Expanded(  // Wrap with Expanded
                  child: Text(
                    'Hotel: ${data['hotel']}',
                    style: TextStyle(fontSize: 16),
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
                  'Doctor: ${data['drname']}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
              children: [
                Icon(Icons.medical_services, color: Colors.blue[900]),
                SizedBox(width: 8),
                Expanded(  // Wrap with Expanded
                  child: Text(
                    'Medical Consultant: ${data['medicalConsultant']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Arrival Date: ${formatDate(data['arrivalDate'] as Timestamp)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Operation Date: ${formatDate(data['opDate'] as Timestamp)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Departure Date: ${formatDate(data['departureDate'] as Timestamp)}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Procedure: ${data['procedureType']}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Package Amount: \$${data['packageAmount']}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          
          Row(
            children: [
              Icon(Icons.note, color: Colors.blue[900]),
              SizedBox(width: 8),
              Expanded(
                child: data['Note'] == ""
                    ? TextButton(
                        onPressed: () => editField(data['id'], context),
                        child: Text(
                          "Add Note",
                          style: TextStyle(fontSize: 16),
                        ))
                    : Text(
                        'Note: ${data['Note']}',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              IconButton(onPressed: () => editField(data['id'], context), icon: Icon(Icons.edit, color: Colors.blue[900]),)
            ],
          ),
        ],
      ),
    ),
  );
}

// ignore: must_be_immutable
class AppointmentCard extends StatelessWidget {
  final DocumentSnapshot data;
  final BuildContext context;
  var collection = FirebaseFirestore.instance.collection("users");
  final currentid = FirebaseAuth.instance.currentUser!.uid;
  AppointmentCard({required this.data, required this.context});

  Future<bool>isClientAdminG(String uid) async {
    DocumentSnapshot clientDoc = await collection.doc(uid).get();
    Map<String, dynamic>? clientData =
        clientDoc.data() as Map<String, dynamic>?;
    if (clientDoc.exists &&
        clientData != null &&
        clientData['part'] == "AdminG") {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = FirebaseAuth.instance.currentUser?.uid;
    return FutureBuilder<bool>(
      future: isClientAdminG(id!),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data == true) {
            // If the client is an AdminG
            return admincard(data, context);
          } else {
            // If the client is not an AdminG or if there was an error
            return card(data);
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the future to complete, you can show a loader or any placeholder
          return Center(child: CircularProgressIndicator());
        } else {
          // Handle any other state, like error
          return Center(child: Text('Error occurred'));
        }
      },
    );
  }
}

class InfoClients extends StatelessWidget {
  final String id;

  InfoClients({required this.id});

  @override
  Widget build(BuildContext context) {
    CollectionReference form = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: form.doc(id).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

        String email = data['email']?.toString() ?? '';

        return Row(
          children: [
            Icon(Icons.email, color: Colors.blue[900]),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
