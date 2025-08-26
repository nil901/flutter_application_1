import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
 Future<void> launchDialer(String number) async {
  final Uri telUrl = Uri.parse('tel:${number}');
  
  // Check for permission before launching the dialer
  var status = await Permission.phone.request();
  
  if (status.isGranted) {
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    } else {
      throw 'Could not launch $telUrl';
    }
  } else {
    print('Phone permission denied');
  }
}
  final String email = "seller.care@gmail.com";
  final String subject = "";
  final String body = "";
 Future<void> launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print("Could not launch email");
    }
  }
  final String websiteUrl = "https://myyvo.com/";
 Future<void> launchWebsite() async {
    final Uri uri = Uri.parse(websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $websiteUrl");
    }
  }
  void openWhatsApp(BuildContext context, phoneNumber, msg) async {
    final url = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(msg)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not open WhatsApp")));
    }
  }

void showTopSnackBar(BuildContext context, String message, Color color) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 50.0, // Adjust position from the top
      left: MediaQuery.of(context).size.width * 0.1,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color, // Dynamic color (red for error, green for success)
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}


}


