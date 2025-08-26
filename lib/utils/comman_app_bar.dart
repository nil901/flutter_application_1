
import 'package:flutter/material.dart';
import 'package:flutter_application_1/color/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;

  const CustomAppBar({Key? key, required this.title, this.onMenuTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kOrange,
      title: Text(title, style: TextStyle(color: Colors.white)),
      
    leading: IconButton(
  icon: Icon(onMenuTap != null ? Icons.menu : Icons.arrow_back, color: Colors.white),
  onPressed: () {
    if (onMenuTap != null) {
      onMenuTap!(); // Trigger the menu callback if provided
    } else {
      
      Navigator.of(context).pop(); // Navigate back if no menu action is provided
    }
  },
),

      centerTitle: false,
      elevation: 4,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
