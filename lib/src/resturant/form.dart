import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

class RestaurantForm extends StatefulWidget {
  final String operation;
  RestaurantForm({Key? key, required this.operation}) : super(key: key);

  @override
  RestaurantFormState createState() {
    return RestaurantFormState(operation);
  }
}

class RestaurantFormState extends State<RestaurantForm> {
  String operation;
  RestaurantFormState(this.operation);
  var collection = FirebaseFirestore.instance.collection("restaurants");
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final currentuser = FirebaseAuth.instance.currentUser!;
  final _imagecontroller = MultiImagePickerController(
      maxImages: 15,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withData: true,
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );

  List<Map<String, dynamic>> _listUrl = [];
  String? _selectedCuisine;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _cuisineTypes = [
    'Italian',
    'Chinese',
    'Indian',
    'Mexican',
    'Japanese',
    'French',
    'Thai',
    'Spanish',
    'Greek',
    'Mediterranean',
  ];

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null && picked != (isStartTime ? _startTime : _endTime)) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future addData(
    String name,
    String address,
    String phone,
    String website,
    String hours,
    String cuisine,
    String description,
    Iterable<ImageFile> images,
  ) async {
    String date = DateTime.now().toString();

    for (final image in images) {
      Reference storageReference;
      if (image.hasPath) {
        storageReference = FirebaseStorage.instance.ref().child(
            'restaurants/${currentuser.uid}/${date}/image${Random().nextInt(10000).toString()}');
        try {
          await storageReference.putFile(File(image.path!));
          String downloadURL = await storageReference.getDownloadURL();
          _listUrl.add({'url': downloadURL});
        } on Exception catch (e) {
          print(e);
        }
      }
    }

    final infoData = {
      "id": currentuser.uid,
      "operation": description,
      "name": name,
      "address": address,
      "phone": phone,
      "website": website,
      "hours": hours,
      "cuisine": cuisine,
      "images": _listUrl,
    };

    await collection.doc(currentuser.uid).set(infoData);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _imagecontroller.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = TimeOfDayFormat.H_colon_mm;
    return TimeOfDay.fromDateTime(dt).format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(operation, style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name',
                    prefixIcon: const Icon(Icons.restaurant),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _websiteController,
                  decoration: InputDecoration(
                    labelText: 'Website URL',
                    prefixIcon: const Icon(Icons.web),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a website URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text("Operating Hours"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Time',
                            labelStyle: TextStyle(color: Color(0xFF0D47A1)),
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_startTime == null
                              ? ''
                              : _formatTime(_startTime)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End Time',
                            labelStyle: TextStyle(color: Color(0xFF0D47A1)),
                            prefixIcon: const Icon(Icons.access_time),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                              _endTime == null ? '' : _formatTime(_endTime)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Cuisine Type',
                    prefixIcon: const Icon(Icons.food_bank),
                  ),
                  value: _selectedCuisine,
                  items: _cuisineTypes.map((String cuisine) {
                    return DropdownMenuItem<String>(
                      value: cuisine,
                      child: Text(cuisine),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCuisine = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a cuisine type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text("Add Photos of the Restaurant"),
                MultiImagePickerView(
                  controller: _imagecontroller,
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      String hours =
                          '${_formatTime(_startTime)} - ${_formatTime(_endTime)}';
                      addData(
                        _nameController.text,
                        _addressController.text,
                        _phoneController.text,
                        _websiteController.text,
                        hours,
                        _selectedCuisine!,
                        _descriptionController.text,
                        _imagecontroller.images,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Restaurant info has been submitted'),
                        ),
                      );
                      Timer(const Duration(seconds: 2), () {
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: const Text('Submit', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
