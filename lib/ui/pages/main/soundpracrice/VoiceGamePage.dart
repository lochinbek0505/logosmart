import 'package:logosmart/ui/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceGamePage extends StatefulWidget {
  const VoiceGamePage({super.key});

  @override
  State<VoiceGamePage> createState() => _VoiceGamePageState();
}

class _VoiceGamePageState extends State<VoiceGamePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/star.webp",
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(width: 12),
                        Image.asset("assets/icons/namber_o.webp", height: 35),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 10,
                        right: 10,
                        top: 8.5,
                        bottom: 11.5,
                      ),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/icons/circle.webp"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: const ProfileAvatar(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: size.width * 0.71,
                // 290,
                height: 200,
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 26,
                  bottom: 11.5,
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/icons/cloud.webp"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Transform.translate(
                  offset: Offset(0, 25),
                  child: Text(
                    "widgets.data.exercise!.steps[0].text",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Image.asset("assets/icons/helicopter.webp"),
              SizedBox(height: 80),
              Image.asset("assets/icons/volume_button.webp"),
              SizedBox(height: 120),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/icons/mic.webp",
                    width: 110,
                    height: 110,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(width: 15),
                  Image.asset(
                    "assets/icons/pause_button.webp",
                    width: 80,
                    height: 80,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
