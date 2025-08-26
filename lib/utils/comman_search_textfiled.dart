import 'package:flutter/material.dart';

class CommonSearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearch;

  const CommonSearchTextField({
    super.key,
    required this.controller,
    required this.onSearch,
    this.hintText = 'Search keyword',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child:   TextField(
            controller: controller,
            onChanged: (_) => onSearch(), // ENTER key press वर सर्च चालेल
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: onSearch, // Search icon वर press केल्यावर
              ),
            ),
          ),
        ),
      ),
    );
  }
}

