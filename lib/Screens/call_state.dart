// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';


// class CallPopupScreen extends StatefulWidget {
//   @override
//   _CallPopupScreenState createState() => _CallPopupScreenState();
// }

// class _CallPopupScreenState extends State<CallPopupScreen> {
//   late StreamSubscription<PhoneStateStatus> _phoneStateSubscription;
//   Timer? _timer;
//   int _callDuration = 0;
//   bool _hasCallStarted = false;
//   bool _isCallEnded = false;

//   String _calledNumber = "7756011548";
//   String _contactName = "Unknown";

//   @override
//   void initState() {
//     super.initState();
//     listenToCallState();
//   }

//   void listenToCallState() async {
//     var permission = await Permission.phone.request();
//     if (permission.isGranted) {
//       _phoneStateSubscription = PhoneState.stream.listen((PhoneState event) {
//         print("Phone State Changed: ${event.status}");

//         if (event.status == PhoneStateStatus.CALL_STARTED) {
//           print("Call Started");
//           _hasCallStarted = true;
//           _isCallEnded = false;

//           Future.delayed(Duration(seconds: 2), () {
//             if (_hasCallStarted && !_isCallEnded) {
//               _startCallTimer();
//             }
//           });
//         }

//         else if (event.status == PhoneStateStatus.CALL_ENDED) {
//           print("Call Ended");
//           _stopCallTimer();

//           if (_hasCallStarted) {
//             setState(() {
//               _isCallEnded = true;
//             });

//             if (mounted) {
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 _showCallEndedPopup(context);
//               });
//             }

//             _hasCallStarted = false;
//           }
//         }

//         else if (event.status == PhoneStateStatus.NOTHING) {
//           print("No active call. Resetting state.");
//           _hasCallStarted = false;
//           _isCallEnded = false;
//           _stopCallTimer();
//         }
//       }) as StreamSubscription<PhoneStateStatus>;
//     }
//   }

//   void _startCallTimer() {
//     print("Starting Call Timer");
//     _callDuration = 0;
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (!_isCallEnded) {
//         setState(() {
//           _callDuration++;
//         });
//         print("Call Duration: $_callDuration");
//       }
//     });
//   }

//   void _stopCallTimer() {
//     print("Stopping Call Timer");
//     if (_timer != null) {
//       _timer!.cancel();
//     }
//   }

//   void _showCallEndedPopup(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         Future.delayed(Duration(seconds: 10), () {
//           if (Navigator.of(context).canPop()) {
//             Navigator.of(context).pop();
//           }
//         });

//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           "You just called....",
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: Icon(Icons.close, color: Colors.red),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   CircleAvatar(
//                     backgroundColor: Colors.blue,
//                     radius: 30,
//                     child: Icon(Icons.check, color: Colors.white, size: 30),
//                   ),
//                   SizedBox(height: 8),
//                   Text(_calledNumber, style: TextStyle(fontSize: 16)),
//                   Text(_formatCallDuration(_callDuration), style: TextStyle(color: Colors.grey)),
//                   SizedBox(height: 16),
//                   _buildDropdown("Select Feedback Status"),
//                   _buildDropdown("Select Priority"),
//                   _buildTextField("Estimation Budget"),
//                   _buildTextField("Remark", maxLines: 2),
//                   SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                     ),
//                     child: Text("Submit"),
//                   ),
//                   SizedBox(height: 10),
//                   Text("Fetching Recording file...Please Wait", style: TextStyle(fontSize: 12)),
//                   SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _formatCallDuration(int duration) {
//     int minutes = (duration % 3600) ~/ 60;
//     int seconds = duration % 60;
//     return "00:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
//   }

//   Widget _buildDropdown(String hint) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8.0),
//       child: DropdownButtonFormField<String>(
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           hintText: hint,
//         ),
//         items: [],
//         onChanged: (value) {},
//       ),
//     );
//   }

//   Widget _buildTextField(String hint, {int maxLines = 1}) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 8.0),
//       child: TextFormField(
//         maxLines: maxLines,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           hintText: hint,
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _phoneStateSubscription.cancel();
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Call Popup Example")),
//       body: Center(child: Text("Call listener is running...")),
//     );
//   }
// }
