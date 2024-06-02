import 'dart:async';

import 'package:flutter/material.dart';


import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';





class AppointmentPage extends StatefulWidget {
  final String id;
  AppointmentPage({Key? key, required this.id}) : super(key: key);

  @override
  _AppointmentPageState createState() => _AppointmentPageState(id);
}

class _AppointmentPageState extends State<AppointmentPage> {
  final String id;
  _AppointmentPageState(this.id);
  DateTime? _arrivalDate;
  DateTime? _opDate;
  DateTime? _departureDate;
  String? _procedureType;
  double? _packageAmount;
  String? _hotel;
  String? _drname;
  String? _medicalConsultant;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _procedureTypes = [
    "Cosmetic Surgery",
    "Dental Treatment",
    "Weight Loss Surgery",
    "Hair Transplant",
    "Other Treatments"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add an Appointment')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildTextField('Hotel', _hotel, (value) {
                _hotel = value;
              }, TextInputType.text),
              SizedBox(height: 16),
              _buildTextField('Doctor Name', _drname, (value) {
                _drname = value;
              }, TextInputType.text),
              SizedBox(height: 16),
              _buildTextField('Medical Consultant', _medicalConsultant,
                  (value) {
                _medicalConsultant = value;
              }, TextInputType.text),
              SizedBox(height: 16),
              _buildDateField("Arrival Date", _arrivalDate, (date) {
                setState(() {
                  _arrivalDate = date;
                });
              }),
              SizedBox(height: 16),
              _buildDateField("Operation Date", _opDate, (date) {
                setState(() {
                  _opDate = date;
                });
              }),
              SizedBox(height: 16),
              _buildDateField("Departure Date", _departureDate, (date) {
                setState(() {
                  _departureDate = date;
                });
              }),
              SizedBox(height: 16),
              _buildTextField('Package Amount', _packageAmount?.toString(),
                  (value) {
                _packageAmount = double.tryParse(value);
              }, TextInputType.number),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Procedure Type',
                  focusColor: Color.fromRGBO(13, 71, 161, 1),
                  fillColor: Color(0xfff3f3f4),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a procedure type';
                  }
                  return null;
                },
                value: _procedureType,
                onChanged: (value) {
                  setState(() {
                    _procedureType = value;
                  });
                },
                items: _procedureTypes.map((type) {
                  return DropdownMenuItem(
                    child: Text(type),
                    value: type,
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _validateDates()) {
                    await saveToFirestore(id);
                    print('Appointment saved!');
                  } else {
                    print('Please fill in all the details correctly.');
                  }
                },
                child: Text('Save the Appointment'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String? initialValue,
      Function(String) onChanged, TextInputType keyboardType) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        labelText: label,
        focusColor: Color.fromRGBO(13, 71, 161, 1),
        fillColor: Color(0xfff3f3f4),
        filled: true,
      ),
      onChanged: (value) {
        onChanged(value);
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        } else if (keyboardType == TextInputType.number) {
          final n = num.tryParse(value);
          if (n == null) {
            return '"$value" is not a valid number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate,
      Function(DateTime?) onDateSelected) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                primaryColor: Colors.blue[900],
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
                colorScheme: ColorScheme.light(primary: Colors.blue.shade900)
                    .copyWith(secondary: Colors.blue[900]),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null && pickedDate != selectedDate)
          onDateSelected(pickedDate);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusColor: Color.fromRGBO(13, 71, 161, 1),
          fillColor: Color(0xfff3f3f4),
          filled: true,
        ),
        child: selectedDate == null
            ? Text(
                "Select a date",
                style: TextStyle(color: Colors.red),
              )
            : Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
      ),
    );
  }

  Future<void> saveToFirestore(id) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(id).set({
        'id': id,
        'arrivalDate': _arrivalDate,
        'opDate': _opDate,
        'departureDate': _departureDate,
        'procedureType': _procedureType,
        'packageAmount': _packageAmount,
        'Note': "",
        'hotel': _hotel,
        'drname': _drname,
        'medicalConsultant': _medicalConsultant,
      }, SetOptions(merge: true));
      
      // Using SetOptions to merge with existing data if the doc already exists.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment saved successfully!')));
      Timer(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (error) {
      print('Error saving to Firestore: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving to Firestore.')));
    }
  }

  bool _validateDates() {
    if (_arrivalDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an Arrival Date.')));
      return false;
    }
    if (_opDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an Operation Date.')));
      return false;
    }
    if (_departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a Departure Date.')));
      return false;
    }
    return true;
  }
}
