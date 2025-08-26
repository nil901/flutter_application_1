import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class CallDialogScreen extends StatefulWidget {
  const CallDialogScreen({super.key});

  @override
  State<CallDialogScreen> createState() => _CallDialogScreenState();
}

class _CallDialogScreenState extends State<CallDialogScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _phoneNoController = TextEditingController();

  @override
  void dispose() {
    _phoneNoController.dispose();
    super.dispose();
  }

  Future<void> _makeACall() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        String number = _phoneNoController.text.trim();
        bool? res = await FlutterPhoneDirectCaller.callNumber(number);
        log('Call success: $res');

        // Show dialog after making the call
        if (res == true) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Call Started'),
                content: const Text('Your call is being connected.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        log('Call failed: $e');
        // Optionally, show a dialog for the error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to make the call: $e'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _endCall() async {
    // In a real scenario, this would be triggered after call ends.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Call Ended'),
          content: const Text('The call has ended.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override            
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Make a Call'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phoneNoController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter phone number';
                    if (value.length < 7) return 'Invalid number';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Phone number',
                    prefixIcon: Icon(Icons.local_phone_rounded, color: Colors.green.shade800, size: 18),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black38),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.green, width: 1.5),
                    ),
                  ),
                  onFieldSubmitted: (_) => _makeACall(),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _makeACall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    minimumSize: const Size(100, 35),
                  ),
                  child: const Text(
                    'Call',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _endCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    minimumSize: const Size(100, 35),
                  ),
                  child: const Text(
                    'End Call',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
