import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Screens/auth/forgot_passworld_screen.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/auth/reset_password_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // @override
  // void dispose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.dispose();
  // }
  bool _isLoading = false;
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    // emailController.text = "sumitpathak@gmail.com";
    // passwordController.text = 'sumit@123';
    // emailController.text = "sumitpathak@gmail.com";
    // passwordController.text = 'sumit@123';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Text('', style: TextStyle(color: kOrange, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    'Pawanputra App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kOrange,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset('assets/images/logo_crm.png', height: 160),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    
            // Email field
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'email_address'.tr,
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TextField(
                  //   controller: passwordController,
                  //   obscureText: _obscureText,
                  //   decoration: InputDecoration(
                  //     hintText: 'password'.tr,
                  //     prefixIcon: const Icon(Icons.lock_outline),
                  //     suffixIcon: IconButton(
                  //       icon: Icon(
                  //         _obscureText
                  //             ? Icons.visibility_off
                  //             : Icons.visibility,
                  //       ),
                  //       onPressed: () {
                  //         setState(() {
                  //           _obscureText = !_obscureText;
                  //         });
                  //       },
                  //     ),
                  //     filled: true,
                  //     fillColor: Colors.white,
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: BorderSide.none,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 16),
    
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          setState(() {
                            _isLoading = true;
                          });
    
                          var dio = Dio();
    
                          Map<String, dynamic> data = {
                            "email": emailController.text,
                          };
    
                          // API Call
                          final response = await ApiService().postRequest(
                            forgotPasswordEndPoint,
                            {"email": emailController.text},
                          );
    
                          print("Response: ${response?.statusCode}");
                          if (response?.statusCode == 200) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResetPasswordScreen(),
                              ),
                            );
                            Utils().showToastMessage(
                              response?.data['message'],
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          } else {
                            // Utils().showToastMessage("response.statusCode");
                            print(
                              '${"login_failed".tr}: ${response?.statusCode}',
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } catch (e) {
                          print('Error during login: $e');
                          print('Error during login: $e');
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: kwhite)
                              : Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: kwhite,
                                ),
                              ),
                    ),
                  ),
    
                  //  SizedBox(height: 16),
    
                  // Sign up link
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text("Don’t have an account? "),
                  //     Text(
                  //       "Sign Up",
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         color: kOrange,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
