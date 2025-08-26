import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String image;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.image,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Material(
            elevation: 2,
            shape: const CircleBorder(),
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  image,
                  height: 40,
                  width: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
