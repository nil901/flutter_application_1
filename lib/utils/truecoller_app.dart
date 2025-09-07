import 'package:flutter/material.dart';

class DialPadWidget extends StatelessWidget {
  final ValueChanged<String> onCall;

  const DialPadWidget({super.key, required this.onCall});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Column(
      children: [
        TextField(controller: controller, keyboardType: TextInputType.phone),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['1','2','3','4','5','6','7','8','9','*','0','#']
              .map((d) => ElevatedButton(
                    onPressed: () => controller.text += d,
                    child: Text(d),
                  ))
              .toList(),
        ),
        FilledButton.icon(
          onPressed: () => onCall(controller.text),
          icon: const Icon(Icons.call),
          label: const Text('Call'),
        ),
      ],
    );
  }
}
