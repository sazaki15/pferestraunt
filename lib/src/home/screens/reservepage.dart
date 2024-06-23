import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationsPage extends StatefulWidget {
  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchUserReservations();
  }

  Future<void> _fetchUserReservations() async {
    setState(() {
      _reservations.clear();
      _isLoading = true;
      _hasError = false;
    });

    User? user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .get()
          .then((querySnapshot) async {
        for (var orderDoc in querySnapshot.docs) {
          await orderDoc.reference.collection('all orders')
              .where('userId', isEqualTo: user.uid)
              .get()
              .then((subQuerySnapshot) {
            for (var doc in subQuerySnapshot.docs) {
              _reservations.add(doc.data() as Map<String, dynamic>);
            }
          });
        }
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching reservations: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reservation['restaurantName'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey),
                SizedBox(width: 10),
                Text(
                  'Date: ${reservation['arrivalDate']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey),
                SizedBox(width: 10),
                Text(
                  'Time: ${reservation['arrivalTime']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey),
                SizedBox(width: 10),
                Text(
                  'Places: ${reservation['numberOfPlaces'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Chip(
              label: Text(
                reservation['status'].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: _getStatusColor(reservation['status']),
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
        title: Text('My Reservations'),
        backgroundColor: Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(child: Text('Error fetching reservations.'))
                : _reservations.isEmpty
                    ? Center(child: Text('No reservations found.'))
                    : ListView.builder(
                        itemCount: _reservations.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> reservation = _reservations[index];
                          return _buildReservationCard(reservation);
                        },
                      ),
      ),
    );
  }
}
