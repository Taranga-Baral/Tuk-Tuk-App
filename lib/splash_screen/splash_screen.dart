import 'package:flutter/material.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo.png', 
          width: MediaQuery.of(context).size.width * 0.7, 
          height: MediaQuery.of(context).size.width * 0.7,
          fit: BoxFit.contain, 
        ),
      ),
    );
  }
}
