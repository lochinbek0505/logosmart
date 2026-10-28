import 'package:logosmart/ui/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WolfHosePage extends StatefulWidget {
  const WolfHosePage({super.key});

  @override
  State<WolfHosePage> createState() => _WolfHosePageState();
}

class _WolfHosePageState extends State<WolfHosePage> {
  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return  Scaffold(
      backgroundColor: Color(0xfff0f0f0),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
              SizedBox(
                  width: size.width,
                  height: 20),
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
                SizedBox(height: 145,),
                SizedBox(
                  width: size.width*0.391,
                  height: size.width*0.482,
                  child: Image.asset("assets/images/wolf.webp",width: 160,height: 200,),
                ),
                SizedBox(height: 75,),
                SizedBox(
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          SizedBox(
                            height: size.width*0.22,
                            width: size.width*0.32,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(

                                    height: size.width*0.21,
                                    width: size.width*0.27,
                                    decoration: BoxDecoration(
                                    image: DecorationImage(image: AssetImage("assets/images/dog_house.webp",))
                                  ),),
                                ),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage("assets/icons/circle.webp"),
                                  child: SizedBox(
                                    child: Image.asset("assets/icons/music.webp",fit: BoxFit.fill,),
                                  ),
                                )

                              ],
                            ),
                          ),
                          SizedBox(width: 20,),
                          SizedBox(
                            height: size.width*0.22,
                            width: size.width*0.32,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(

                                    height: size.width*0.21,
                                    width: size.width*0.27,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(image: AssetImage("assets/images/cave.webp",))
                                    ),),
                                ),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage("assets/icons/circle.webp"),
                                  child: SizedBox(
                                    child: Image.asset("assets/icons/music.webp",fit: BoxFit.fill,),
                                  ),
                                )

                              ],
                            ),
                          ),

                        ],
                      ),
                      SizedBox(height: 40,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          SizedBox(
                            height: size.width*0.22,
                            width: size.width*0.32,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(

                                    height: size.width*0.21,
                                    width: size.width*0.27,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(image: AssetImage("assets/images/bird_house.webp",))
                                    ),),
                                ),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage("assets/icons/circle.webp"),
                                  child: SizedBox(
                                    child: Image.asset("assets/icons/music.webp",fit: BoxFit.fill,),
                                  ),
                                )

                              ],
                            ),
                          ),
                          SizedBox(width: 20,),
                          SizedBox(
                            height: size.width*0.22,
                            width: size.width*0.32,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(

                                    height: size.width*0.21,
                                    width: size.width*0.27,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(image: AssetImage("assets/images/house.webp",))
                                    ),),
                                ),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage("assets/icons/circle.webp"),
                                  child: SizedBox(
                                    child: Image.asset("assets/icons/music.webp",fit: BoxFit.fill,),
                                  ),
                                )

                              ],
                            ),
                          ),

                        ],
                      ),


                    ],
                  ),
                )


              ]
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 210,
                width: size.width,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 57,right: 60),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage("assets/icons/circle.webp"),
                          child: SizedBox(
                            child: Image.asset("assets/icons/music.webp",fit: BoxFit.fill,),
                          ),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(

                        height: 130,
                        width: size.width*0.78,
                        decoration: BoxDecoration(
                            image: DecorationImage(image: AssetImage("assets/images/top_cloud.webp",))
                        ),
                      child: Transform.translate(
                        offset: Offset(-15, 32),
                        child: Text("Bo'ri qayerda yashaydi?\nQay birida R tovushi\nqatnashgan!",
                          textAlign:TextAlign.center,
                          style: TextStyle(
                          color: Color(0xff093e5e),
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp

                        ),),
                      ),
                      ),
                    ),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
