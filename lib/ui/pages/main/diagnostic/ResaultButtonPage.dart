import 'package:flutter/material.dart';

class ResaultButtonPage extends StatefulWidget {
  const ResaultButtonPage({super.key});

  @override
  State<ResaultButtonPage> createState() => _ResaultButtonPageState();
}

class _ResaultButtonPageState extends State<ResaultButtonPage> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return  Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backround_xira.png"),
            fit: BoxFit.fill,
          ),
        ),

        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20,width: size.width,),
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
                  SizedBox(height: 30,),

                  Container(
                    width: size.width*0.67,// 290,
                    height:165,
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 8.5,
                      bottom: 11.5,
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/icons/cloud.png"),
                          fit: BoxFit.fill
                      ),
                    ),
                    child: Transform.translate(
                      offset: Offset(0, 10),
                      child: Text(
                        "Barakalla, sen\ntopshiriqlarni\nbajarding!",
                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.blueGrey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.width*0.82,
                  ),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPressed = true;
                      });
                      Future.delayed(const Duration(milliseconds: 160), () {
                        setState(() {
                          _isPressed = false;
                        });
                      });

                      Future.delayed(const Duration(milliseconds: 180), () {
                       // Navigator.of(context).push(MaterialPageRoute(builder: (_) =>  CameraPage()),);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(7),
                      width: size.width * 0.7,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: _isPressed
                          ? Container(
                        width: size.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xff20B9E8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            "NATIJALAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        padding: EdgeInsets.only(bottom: 3),
                        width: size.width,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xff47809e),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Container(
                          padding: EdgeInsets.only(top: 2),
                          width: 190,
                          height: 57,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(29),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffbee9f7),
                                Color(0xff20B9E8),
                              ],
                              end: Alignment.bottomCenter,
                              begin: Alignment.topCenter,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "NATIJALAR",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30,)
                ],
              ),
            ),
            SafeArea(
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 300,width: size.width,),
                  SizedBox(
                    width: size.width*0.43,
                    height: size.width*0.85,
                    child: Image.asset("assets/images/women.png",fit: BoxFit.fill,),
                  ),
                ],
              ),
            ),







          ],
        ),
      ),
    );  }
}
