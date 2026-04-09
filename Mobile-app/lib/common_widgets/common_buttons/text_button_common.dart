import 'package:flutter/material.dart';

class TextButtonCommon extends StatefulWidget {
  Color buttonColor;
  Function() onTap;
  String buttonText;
  TextButtonCommon(
      {super.key,
        required this.buttonColor,
        required this.onTap,
        required this.buttonText});

  @override
  State<TextButtonCommon> createState() => _TextButtonCommonState();
}

class _TextButtonCommonState extends State<TextButtonCommon> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.onTap,
      child: Text(
        widget.buttonText,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
