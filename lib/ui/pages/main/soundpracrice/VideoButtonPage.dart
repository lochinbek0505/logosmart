import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/WolfHosePage.dart';

class VideoButtonPage extends StatefulWidget {
  const VideoButtonPage({super.key});

  @override
  State<VideoButtonPage> createState() => _VideoButtonPageState();
}

class _VideoButtonPageState extends State<VideoButtonPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,

        child: Stack(
          children: [
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
                        SizedBox(height: 140,),
                        Container(
                          width: size.width * 0.9,
                          height: size.width * 0.9,
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
                        SizedBox(height: 100,),
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>WolfHosePage()));
                          },
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage("assets/icons/circle.png"),
                            child: SizedBox(
                              child: Transform.translate(
                                  offset: Offset(-0.5, -1),
                                  child: Image.asset("assets/icons/pause.png",width: 34,)),
                            ),
                          ),
                        )
                      ],
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
