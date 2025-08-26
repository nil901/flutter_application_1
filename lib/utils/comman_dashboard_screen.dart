
import 'package:flutter/material.dart';
import 'package:flutter_application_1/color/colors.dart';

class CustomDropdown extends StatelessWidget {
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kOrange, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<String>(
          value: selectedItem,
          isExpanded: true,
          underline: const SizedBox(),
          icon: Icon(Icons.arrow_drop_down, color: kOrange),
          style: TextStyle(
            color: kOrange, // 👈 Selected item text color
            fontSize: 16,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: item == selectedItem ? kOrange : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
