import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/firstspeech/FinishButtonPage.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) =>  FinishButtonPage()),);
    });

  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,

        child: Stack(
          children: [
            SizedBox(
              width:size.width,
              height: size.height,
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                "assets/icons/arrow_right_button.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Image.asset(
                                "assets/icons/star.png",
                                width: 40,
                                height: 40,
                              ),
                              SizedBox(width: 12),
                              Image.asset(
                                "assets/icons/namber_o.png",
                                height: 35,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/backround_xira.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: size.width, height: 115),
                Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white

                  ),
                  padding: EdgeInsets.all(5),
                  child: Container(
                    padding: EdgeInsets.all(5),

                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(  colors: [
                        Color(0xffbee9f7),
                        Color(0xff20B9E8),
                      ],
                        end: Alignment.bottomCenter,
                        begin: Alignment.topCenter,)
                    ),
                    child: Container(
                        width: double.infinity,
                        height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white,
                        image: DecorationImage(image: AssetImage("assets/images/yarimta_qizcha.png"),)


                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8,),
                Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white

                  ),
                  padding: EdgeInsets.all(5),
                  child: Container(
                    padding: EdgeInsets.all(5),

                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(  colors: [
                          Color(0xffbee9f7),
                          Color(0xff20B9E8),
                        ],
                          end: Alignment.bottomCenter,
                          begin: Alignment.topCenter,)
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white,
                          image: DecorationImage(image: AssetImage("assets/images/camera_girl.png"),fit: BoxFit.fill)



                      ),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
