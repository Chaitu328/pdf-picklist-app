import 'package:flutter/material.dart';

import '../app_utils/text_constants.dart';

class ShowMoreTextWidget extends StatefulWidget {
  final String text; // Text passed as a parameter

  // Constructor to accept text
  ShowMoreTextWidget({required this.text});

  @override
  _ShowMoreTextWidgetState createState() => _ShowMoreTextWidgetState();
}

class _ShowMoreTextWidgetState extends State<ShowMoreTextWidget> {
  bool _isExpanded = false; // To track if the text is expanded or not

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display either truncated text or full text based on _isExpanded
        Text(
          _isExpanded
              ? widget.text
              : widget.text.substring(0, 80) +
                  '...', // Show truncated or full text
          style: TextStyle(fontSize: 15, color: Colors.black),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded; // Toggle the expanded state
            });
          },
          child: Text(
            _isExpanded ? 'Show Less' :TextConstants.showMore,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
