import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/Screens/auth/forgot_passworld_screen.dart';
import 'package:flutter_application_1/Screens/auth/login_notifier.dart';
import 'package:flutter_application_1/Screens/auth/login_screen.dart';
import 'package:flutter_application_1/Screens/dashboard_screen.dart';
import 'package:flutter_application_1/api_service/api_service.dart';
import 'package:flutter_application_1/api_service/urls.dart';
import 'package:flutter_application_1/color/colors.dart';
import 'package:flutter_application_1/global/utils.dart';
import 'package:flutter_application_1/prefs/PreferencesKey.dart';
import 'package:flutter_application_1/prefs/app_preference.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  // @override
  // void dispose() {
  //   emailController.dispose();
  //   passwordController.dispose();
  //   super.dispose();
  // }
  bool _isLoading = false;
  bool _obscureText = true;

  bool _obscureConfirmText = true;
  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    // emailController.text = "sumitpathak@gmail.com";
    // passwordController.text = 'sumit@123';
    // emailController.text = "sumitpathak@gmail.com";
    // passwordController.text = 'sumit@123';
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return false;
      },
      child: Scaffold(
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
                        hintText: 'OTP',
                        prefixIcon: Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmText,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmText = !_obscureConfirmText;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
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
                          if (emailController.text.isEmpty) {
                            Utils().showToastMessage("Please enter OTP");
                            return;
                          }

                          if (passwordController.text.isEmpty) {
                            Utils().showToastMessage("Please enter password");
                            return;
                          }

                          if (confirmPasswordController.text.isEmpty) {
                            Utils().showToastMessage(
                              "Please confirm your password",
                            );
                            return;
                          }

                          // Optional: Check if password and confirm password match
                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            Utils().showToastMessage("Passwords do not match");
                            return;
                          }

                          // Continue with registration...

                          try {
                            setState(() {
                              _isLoading = true;
                            });

                            var dio = Dio();

                            Map<String, dynamic> data = {
                              "email": emailController.text,
                              "password": passwordController.text,
                            };

                            // API Call
                            final response = await ApiService()
                                .postRequest(resetPasswordEndPoint, {
                                  "otp": emailController.text,
                                  "newPassword": passwordController.text,
                                  "confirmPassword":
                                      confirmPasswordController.text,
                                });

                            print("Response: ${response?.statusCode}");
                            if (response?.statusCode == 200) {
                              // final token = response?.data['token'];
                              // final user = response?.data['user'];
                              // final mobile = response?.data['user']['phone'];
                              // final email = response?.data['user']['email'];
                              // final name = response?.data['user']['firstName'];
                              // final memberId =
                              //     response?.data['user']['memberId'];

                              // if (user != null) {
                              //   final userJson = jsonEncode(user);
                              //   final phone = jsonEncode(user);
                              //   // final email = jsonEncode(email);
                              //   await AppPreference().setString(
                              //     PreferencesKey.token,
                              //     userJson,
                              //   );
                              //   await AppPreference().setString(
                              //     PreferencesKey.mobile_no,
                              //     mobile,
                              //   );
                              //   await AppPreference().setString(
                              //     PreferencesKey.email_id,
                              //     email,
                              //   );
                              //   await AppPreference().setString(
                              //     PreferencesKey.name,
                              //     name,
                              //   );
                              //   await AppPreference().setInt(
                              //     PreferencesKey.member_Id,
                              //     memberId,
                              //   );
                              // }
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => StackDashboard(),
                              //   ),
                              // );
                              //  Utils().showToastMessage("Login successful");
                              // } else {
                              //   Utils().showToastMessage("Token missing in response");
                              // }

                              // print("Token: $token");
                              // print("User: $user");
                              Utils().showToastMessage(
                                "${response?.data['message']}",
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
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
                                  "Reset Password",
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
      ),
    );
  }
}
