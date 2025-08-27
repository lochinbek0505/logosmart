import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinishButtonPage extends StatefulWidget {
  const FinishButtonPage({super.key});

  @override
  State<FinishButtonPage> createState() => _FinishButtonPageState();
}

class _FinishButtonPageState extends State<FinishButtonPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backround/backround_mashgulotlar.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            SizedBox(
              width: size.width,
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
                          Row(
                            children: [
                              Image.asset(
                                "assets/icons/star.png",
                                width: 40,
                                height: 40,
                              ),
                              SizedBox(width: 12),
                              Image.asset("assets/icons/namber_o.png", height: 35),
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
                                image: AssetImage("assets/icons/circle.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(
                                "assets/icons/circle_bad.png",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/backround/backround_mashgulotlar.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 240),

                      SizedBox(
                        width: 230,
                        height: 120,
                        child: Stack(

                          children: [
                            Positioned(
                              top: 28,
                              child: Row(children: [
                                Image.asset("assets/icons/star_orange.png",width: 75,height: 75,),
                                SizedBox(width: 80,),
                                Image.asset("assets/icons/star_grey.png",width: 75,height: 75,)

                              ],),
                            ),
                            Positioned(
                              left: 65,
                                child: Image.asset("assets/icons/star_orange.png",width: 100,height: 100,))



                          ],
                        ),
                      ),
                      Text("BOSQICH",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.white),),
                      Text("1",style: GoogleFonts.itim(fontSize: 120,fontWeight: FontWeight.bold,color: Colors.white,        height: 0.9,
                      ),),

                      SizedBox(height: 130),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage("assets/images/circle_red.png"),
                            child: Transform.translate(
                              offset: Offset(0, -1),
                              child: Image.asset(
                                "assets/images/x.png",
                                width: 23,
                                height: 25,
                              ),
                            ),
                          ),

                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage("assets/icons/circle.png"),
                            child: Transform.translate(
                              offset: Offset(1, -2),
                              child: Image.asset(
                                "assets/icons/qayta_yuklash.png",
                                width: 40,
                                height: 38,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage("assets/icons/circle.png"),
                            child: Transform.translate(
                              offset: Offset(0, -1),
                              child: Image.asset(
                                "assets/icons/right_icon.png",
                                width: 23,
                                height: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),



          ],
        ),

      ),
    );  }
}
