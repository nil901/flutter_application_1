import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Privacy Policy - Developers"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Last updated: July 29, 2024'),
              SizedBox(height: 16),
              Text(
                'This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service...\n',
              ),
              Text(
                'When you visit our website or application and use our services, you trust us with your personal information. We take your privacy very seriously...\n',
              ),
              SizedBox(height: 16),
              Text(
                'PRODUCT AND USAGE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'The Product Crm is available only in the application format and can be accessed through Google Play Store and Apple App Store. The application requires login...\n',
              ),
              // Add more sections as needed, truncating for display purpose
              SizedBox(height: 24),
              Text(
                'Note: Wherever "Vscrm" or old references existed, they have been renamed or replaced with "Developers".',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
