import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Checkout extends StatefulWidget {
  final String id;
  final String name;
  final String img;
  final bool isFav;
  final double rating;
  final int raters;
  final String cuisine;
  final String hours;
  final String phone;
  final String website;
  final String description;

  Checkout({
    required this.id,
    required this.name,
    required this.img,
    required this.isFav,
    required this.rating,
    required this.raters,
    required this.cuisine,
    required this.hours,
    required this.phone,
    required this.website,
    required this.description,
  });

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final TextEditingController _couponlControl = TextEditingController();

  DateTime? _arrivalDate;
  TimeOfDay? _arrivalTime;
  String? _userName;
  String? _userEmail;
  int _numberOfPlaces = 1; // Variable to hold the selected number of places

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          _userName = userDoc['name'] ?? "John Doe"; // 'name' should match the field name in Firestore
          _userEmail = user.email ?? "email@example.com";
        });
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          _userName = "John Doe";
          _userEmail = user.email ?? "email@example.com";
        });
      }
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final timeParts = timeString.split(' ');
    final hourMinuteParts = timeParts[0].split(':');
    final hour = int.parse(hourMinuteParts[0]);
    final minute = int.parse(hourMinuteParts[1]);
    final period = timeParts[1];

    return TimeOfDay(
      hour: period == 'AM' ? hour % 12 : hour % 12 + 12,
      minute: minute,
    );
  }

  TimeOfDay _getStartTime() {
    final startTimeString = widget.hours.split(' - ')[0];
    return _parseTime(startTimeString);
  }

  TimeOfDay _getEndTime() {
    final endTimeString = widget.hours.split(' - ')[1];
    return _parseTime(endTimeString);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _arrivalTime ?? TimeOfDay.now(),
    );
    if (picked != null && _isWithinOperatingHours(picked)) {
      setState(() {
        _arrivalTime = picked;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a time within operating hours.')),
      );
    }
  }

  bool _isWithinOperatingHours(TimeOfDay time) {
    final startTime = _getStartTime();
    final endTime = _getEndTime();

    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final selectedMinutes = time.hour * 60 + time.minute;

    if (endMinutes > startMinutes) {
      return selectedMinutes >= startMinutes && selectedMinutes <= endMinutes;
    } else {
      return selectedMinutes >= startMinutes || selectedMinutes <= endMinutes;
    }
  }

  void _placeOrder() async {
    if (_arrivalDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date.')),
      );
      return;
    }
     if (_arrivalTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a time.')),
    );
    return;
  }


    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final orderInfo = {
          'userId': user.uid,
          'userName': _userName,
          'userEmail': _userEmail,
          'restaurantId': widget.id,
        
          'restaurantName': widget.name,
          'arrivalDate': _arrivalDate?.toIso8601String().split('T')[0],
          'arrivalTime': _arrivalTime?.format(context),
          'couponCode': _couponlControl.text,
          'numberOfPlaces': _numberOfPlaces, // Include number of places in the order data
          'status': 'pending',
        };

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.id)
            .collection('all orders')
            .doc(user.uid)
            .set(orderInfo);

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.id)
            .set({'id': widget.id});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order placed successfully!')),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF0D47A1),
        title: Text(
          "Checkout",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            tooltip: "Back",
            icon: Icon(
              Icons.clear,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 130),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Pick a Date: ${_arrivalDate != null ? _arrivalDate!.toLocal().toString().split(' ')[0] : ''}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _arrivalDate ?? DateTime.now(),
                      firstDate: DateTime.now(),  // User can't pick date before current date
                      lastDate: DateTime(2101),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            primaryColor: Color(0xFF0D47A1),
                            buttonTheme: ButtonThemeData(
                                textTheme: ButtonTextTheme.primary),
                            colorScheme:
                                ColorScheme.light(primary: Color(0xFF0D47A1))
                                    .copyWith(secondary: Color(0xFF0D47A1)),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _arrivalDate = pickedDate;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Pick a Time: ${_arrivalTime != null ? _arrivalTime!.format(context) : ''}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  onPressed: () => _selectTime(context),
                  icon: Icon(
                    Icons.edit,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Number of Places: $_numberOfPlaces",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog<int>(
                      context: context,
                      builder: (BuildContext context) {
                        return NumberPickerDialog(
                          initialValue: _numberOfPlaces,
                          minValue: 1,
                          maxValue: 20,
                        );
                      },
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          _numberOfPlaces = value;
                        });
                      }
                    });
                  },
                  icon: Icon(Icons.edit, color: Color(0xFF0D47A1)),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            ListTile(
              title: Text(
                _userName ?? "Loading...",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(_userEmail ?? "Loading..."),
            ),
            SizedBox(height: 10.0),
            Text(
              "Payment Method",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            Card(
              elevation: 4.0,
              child: ListTile(
                title: Text(
                  _userName ?? "Loading...",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  "Payment will be made upon arrival at the restaurant.",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                leading: Icon(
                  FontAwesomeIcons.creditCard,
                  size: 50.0,
                  color: Color(0xFF0D47A1),
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              "Restaurant",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            Card(
              elevation: 4.0,
              child: ListTile(
                leading: Image.network(
                  widget.img,
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                title: Text(widget.name),
                subtitle: Text(widget.cuisine),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Card(
        elevation: 4.0,
        child: Container(
          height: 130,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      hintText: "Coupon Code",
                      prefixIcon: Icon(
                        Icons.redeem,
                        color: Color(0xFF0D47A1),
                      ),
                      hintStyle: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ),
                    ),
                    maxLines: 1,
                    controller: _couponlControl,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 150.0,
                    height: 50.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0D47A1),
                      ),
                      child: Text(
                        "Place Order".toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: _placeOrder,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberPickerDialog extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;

  NumberPickerDialog({
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
  });

  @override
  _NumberPickerDialogState createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Number of Places"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Number of Places"),
          SizedBox(height: 20),
          NumberPicker(
            minValue: widget.minValue,
            maxValue: widget.maxValue,
            value: _currentValue,
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text("CANCEL"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.of(context).pop(_currentValue);
          },
        ),
      ],
    );
  }
}

class NumberPicker extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final int value;
  final ValueChanged<int> onChanged;

  NumberPicker({
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.remove, color: Color(0xFF0D47A1)),
          onPressed: value > minValue
              ? () => onChanged(value - 1)
              : null,
        ),
        Text(value.toString(),
            style: TextStyle(fontSize: 32.0, color: Color(0xFF0D47A1))),
        IconButton(
          icon: Icon(Icons.add, color: Color(0xFF0D47A1)),
          onPressed: value < maxValue
              ? () => onChanged(value + 1)
              : null,
        ),
      ],
    );
  }
}
