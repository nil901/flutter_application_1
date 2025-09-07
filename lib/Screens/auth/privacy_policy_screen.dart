import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/comman_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor:   Colors.orange.shade50,
      appBar: CustomAppBar(title: "Privacy Policy"),
      body: Container(
        
        color: Colors.orange.shade50,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "1. Introduction",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you how we handle your data.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "2. Information We Collect",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "- Personal identification information\n"
                "- Contact details\n"
                "- Device information",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "3. How We Use Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "We use your data to improve our services, provide personalized content, and ensure app functionality.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "4. Data Protection",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "We implement a variety of security measures to maintain the safety of your personal information.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),

              Text(
                "5. Contact Us",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "If you have any questions about this Privacy Policy, please contact us at diginetsolution.info@gmail.com",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
