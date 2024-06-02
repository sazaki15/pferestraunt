import 'package:flutter/material.dart';




class TextFieldWidget extends StatelessWidget {
  final String label;
  final String text;
  final void Function()? onPressed;
  const TextFieldWidget({
    super.key,
    required this.label,
    required this.text,
    required this.onPressed, });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        
        children: [
          Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label ,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                 color: Colors.blue[900],
                  
                ),
              ),
              
              IconButton(
                icon: Icon(Icons.edit),
                color: Colors.blue[900],
                onPressed:onPressed,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 4),
        ],
      )  
    );
  }
}