import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/AppColors.dart';

class Onboard3Page extends StatefulWidget {
  const Onboard3Page({super.key});

  @override
  State<Onboard3Page> createState() => _Onboard3PageState();
}

class _Onboard3PageState extends State<Onboard3Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              "assets/images/onboard3.png",
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
