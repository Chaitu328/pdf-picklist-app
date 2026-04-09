import 'package:flutter/material.dart';

import '../../app_utils/color_constants.dart';

class CommonTextField extends StatefulWidget {
  TextEditingController textFieldController;
  String labelText;
  String? errorText;
  bool obscureText;
  String keyType;
  CommonTextField(
      {required this.textFieldController,
      required this.labelText,
      required this.errorText,
      required this.obscureText,
      required this.keyType,
      super.key});

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType:
          widget.keyType == "num" ? TextInputType.number : TextInputType.text,
      controller: widget.textFieldController,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: AppColor.cPrimaryButtonColor),
        labelText: widget.labelText,
        errorText: widget.errorText,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: AppColor.cPrimaryButtonColor,
              width: 2.0), // Highlight color set to green
        ),
      ),
      obscureText: widget.obscureText,
    );
  }
}
