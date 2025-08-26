import 'package:flutter/material.dart';

class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPage();
}

class _DiagnosticPage extends State<DiagnosticPage> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.green.shade300,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backround_frame.png"),
            fit: BoxFit.fill,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Center(
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
                      SizedBox(height: 30),
                      Container(
                        width: size.width*0.75,// 290,
                        height:202,
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 22,
                          bottom: 11.5,
                        ),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/big_cloud.png"),
                            fit: BoxFit.fill
                          ),
                        ),
                        child: Transform.translate(
                          offset: Offset(0, 10),
                          child: Text(
                            "Rasmlarni nomini\nayting! Tashxislarni\nshovqinsiz olib\nboring.",
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
                            //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()),);
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
                                      "BOSHLASH",
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
                                        "BOSHLASH",
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
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 300,),
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
        ),
      ),
    );
  }
}
