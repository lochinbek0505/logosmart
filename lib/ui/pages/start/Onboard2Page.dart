import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/AppColors.dart';

class Onboard2Page extends StatefulWidget {
  const Onboard2Page({super.key});

  @override
  State<Onboard2Page> createState() => _Onboard2PageState();
}

class _Onboard2PageState extends State<Onboard2Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              "assets/images/onboard2.png",
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Text(
              "Logosmart ilovasiga \nXush kelibsiz!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.sky_blue_900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Text(
              "The app is designed for children and their caregivers to learn about autism, find resources and connect with others in the community. Let's get started!",
              style: TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
