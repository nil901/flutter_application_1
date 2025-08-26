import 'package:flutter/material.dart';
import 'package:flutter_application_1/color/colors.dart';

class CommonTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType inputType;

  const CommonTextField({
    super.key,
    required this.label,
    this.controller,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
     padding: EdgeInsets.zero,
      decoration: BoxDecoration( 
         color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.grey[600],fontSize: 15),
            hintText: label,
            border: InputBorder.none
          ),
          // decoration: InputDecoration(
          //   labelText: label,
          //   labelStyle: const TextStyle(color: Colors.orange),
          //   prefixIcon: icon != null ? Icon(icon, color: Colors.orange) : null,
          //   focusedBorder: OutlineInputBorder(
          //     borderSide: const BorderSide(color: Colors.orange),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   enabledBorder: OutlineInputBorder(
          //     borderSide: const BorderSide(color: Colors.orange),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          // ),
          cursorColor: Colors.orange,
        ),
      ),
    );
  }
}

class HintTextCustom extends StatelessWidget {
  const HintTextCustom({super.key, this.text});
  final text;

  @override
  Widget build(BuildContext context) {
    return Text("$text",style: TextStyle(fontSize: 13,color: kBlack,fontWeight: FontWeight.w500),);
  }
}