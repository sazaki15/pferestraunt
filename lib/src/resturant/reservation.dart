import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationPage extends StatefulWidget {
  final String restaurantId;

  ReservationPage({required this.restaurantId});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime _selectedDate = DateTime.now();
  Future<List<Map<String, dynamic>>>? _reservationsFuture;
  Map<DateTime, List<Map<String, dynamic>>> _reservationsByDate = {};

  @override
  void initState() {
    super.initState();
    _fetchReservationsForMonth(_selectedDate);
    _fetchReservations(_selectedDate);
  }

  Future<void> _fetchReservationsForMonth(DateTime date) async {
    DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
    DateTime lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.restaurantId)
        .collection('all orders')
        .where('arrivalDate',
            isGreaterThanOrEqualTo: firstDayOfMonth.toIso8601String())
        .where('arrivalDate',
            isLessThanOrEqualTo: lastDayOfMonth.toIso8601String())
        .get()
        .then((Snapshot) => Snapshot.docs.forEach((element) {
              DateTime arrivalDate = DateTime.parse(element['arrivalDate']);
              if (_reservationsByDate[arrivalDate] == null) {
                _reservationsByDate[arrivalDate] = [];
              }
              _reservationsByDate[arrivalDate]!
                  .add(element.data() as Map<String, dynamic>);
            }));
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _fetchReservations(DateTime date) async {
    List<Map<String, dynamic>> reservations = [];

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.restaurantId)
        .collection('all orders')
        .where('arrivalDate', isEqualTo: date.toIso8601String().split('T')[0])
        .get()
        .then((Snapshot) => Snapshot.docs.forEach((element) {
              reservations.add(element.data());
            }));
    return reservations;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
      _reservationsFuture = _fetchReservations(selectedDay);
    });
  }

  void _showAllReservations() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('All Reservations'),
          content: Container(
            width: double.maxFinite,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchReservations(
                  DateTime.now()), // Fetch reservations for the current day
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error fetching reservations: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No reservations found.'));
                } else {
                  final reservations = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      return ListTile(
                        title: Text(reservation['userName'] ?? 'No Name'),
                        subtitle: Text(reservation['userEmail'] ?? 'No Email'),
                        trailing: Text(reservation['arrivalTime'] ?? 'No Time'),
                        onTap: () {
                          _showUpdateStatusDialog(reservation);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStatusDialog(Map<String, dynamic> reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Reservation Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Client: ${reservation['userName']}'),
              Text('Email: ${reservation['userEmail']}'),
              Text('Date: ${reservation['arrivalDate']}'),
              Text('Time: ${reservation['arrivalTime']}'),
              Text('number Of Places: ${reservation['numberOfPlaces']}'),
              Text('Status: ${reservation['status']}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                _updateReservationStatus(reservation, 'confirmed');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _updateReservationStatus(reservation, 'cancelled');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateReservationStatus(
      Map<String, dynamic> reservation, String status) async {
    try {
      String userId = reservation['userId'];
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.restaurantId)
          .collection('all orders')
          .doc(userId)
          .update({'status': status});

      setState(() {
        _reservationsFuture = _fetchReservations(_selectedDate);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation status updated to $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating reservation status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservations'),
        backgroundColor: Color(0xFF0D47A1),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showAllReservations,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: _onDaySelected,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (_reservationsByDate[day] != null &&
                    _reservationsByDate[day]!.isNotEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(6.0),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle().copyWith(color: Colors.white),
                    ),
                  );
                }
                return null;
              },
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue[400],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF0D47A1),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Color(0xFF0D47A1),
                fontSize: 16.0,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Color(0xFF0D47A1),
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Color(0xFF0D47A1),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _reservationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error fetching reservations: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No reservations for this date.'));
                } else {
                  final reservations = snapshot.data!;
                  return ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      return ListTile(
                        title: Text(reservation['userName'] ?? 'No Name'),
                        subtitle: Text(reservation['userEmail'] ?? 'No Email'),
                        trailing: Text(reservation['arrivalTime'] ?? 'No Time'),
                        onTap: () {
                          _showUpdateStatusDialog(reservation);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
