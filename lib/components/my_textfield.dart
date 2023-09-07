import 'package:flash_chat_app/constants.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.hintText,
    required this.onChnage,
  });

  final String hintText;
  final Function(String) onChnage;

  @override
  Widget build(BuildContext context) {
    return TextField(
        onChanged: onChnage,
        decoration: kTextFieldDecoration.copyWith(hintText: hintText));
  }
}
