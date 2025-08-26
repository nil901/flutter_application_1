import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/langauage_select_screen.dart';
import 'package:flutter_application_1/api_service/splash_service.dart';


class RippleSplashScreen extends StatefulWidget {
  @override
  _RippleSplashScreenState createState() => _RippleSplashScreenState();
}

class _RippleSplashScreenState extends State<RippleSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rippleSize;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _rippleSize = Tween<double>(begin: 100, end: 200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Wait 1 second after animation ends for smooth feel
     
        SplashServices().checkAuthentication(context);
      
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Color kOrangeLight = Color(0xFFFFE5B4);
  Color kOrange = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOrangeLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rippleSize,
                  builder: (context, child) => Container(
                    width: _rippleSize.value,
                    height: _rippleSize.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kOrange.withOpacity(0.2),
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/logo_crm.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Text(
              'Pawanputra',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: kOrange,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'developer',
              style: TextStyle(
                fontSize: 16,
                color: kOrange.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
