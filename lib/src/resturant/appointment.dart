import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentListPage extends StatefulWidget {
  final String uid;

  AppointmentListPage({required this.uid});

  @override
  _AppointmentListPageState createState() => _AppointmentListPageState(uid: uid);
}

class _AppointmentListPageState extends State<AppointmentListPage> {
  final String uid;

  _AppointmentListPageState({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Appointments'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return Center(child: Text("No appointment found."));
          }

          return ListView(
            children: [
              SizedBox(height: 16),
              AppointmentCard(data: snapshot.data!)],
          );
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final DocumentSnapshot data;

  AppointmentCard({required this.data});

  String formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(  // Wrap with Expanded
                  child: Text(
                    'Dr Name: ${data['drname']}',
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
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue[900]),
                SizedBox(width: 8),
                Expanded(  // Wrap with Expanded
                  child: Text(
                    'Arrival Date: ${formatDate(data['arrivalDate'])}',
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
                Expanded(  // Wrap with Expanded
                  child: Text(
                    'Operation Date: ${formatDate(data['opDate'])}',
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
                Expanded(  // Wrap with Expanded
                  child: Text(
                    'Departure Date: ${formatDate(data['departureDate'])}',
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
                Expanded(  // Wrap with Expanded
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
}
