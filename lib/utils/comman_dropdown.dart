import 'package:flutter/material.dart';

class CommonDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) getLabel;
  final ValueChanged<T?> onChanged;
  final Color backgroundColor;
  final Color iconColor;
  final double borderRadius;
  final Color borderColor;

  const CommonDropdown({
    Key? key,
    required this.hint,
    required this.value,
    required this.items,
    required this.getLabel,
    required this.onChanged,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.borderRadius = 10.0,
    this.borderColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      isDense: true, // Shrinks the dropdown height
      icon: Icon(Icons.arrow_drop_down, size: 20, color: iconColor),
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[300],
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
        ),
      ),
      value: value,
      hint: Text(
        hint,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
      ),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
      ), // Dropdown text size
      items:
          items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                getLabel(item),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14), // Inside dropdown
              ),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }
}
