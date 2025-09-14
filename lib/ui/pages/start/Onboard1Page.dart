import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/AppColors.dart';

class Onboard1Page extends StatefulWidget {
  const Onboard1Page({super.key});

  @override
  State<Onboard1Page> createState() => _Onboard1PageState();
}

class _Onboard1PageState extends State<Onboard1Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              "assets/images/onboard1.png",
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
