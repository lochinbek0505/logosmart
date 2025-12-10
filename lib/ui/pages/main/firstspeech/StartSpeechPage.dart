import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/StartButtonPage.dart';

class StartSpeechPage extends StatefulWidget {
  const StartSpeechPage({super.key});

  @override
  State<StartSpeechPage> createState() => _StartSpeechPageState();
}

class _StartSpeechPageState extends State<StartSpeechPage> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xfff0f0f0),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backround_xira.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      SizedBox(height: 210,),
                      SizedBox(
                        width: size.width*0.65,
                        height: size.width*1.265,
                        child: Image.asset("assets/images/women.png",fit: BoxFit.fill,),
                      ),
                    ],
                  ),
                ),

                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 60),
                      Container(
                        width: size.width*0.67,// 290,
                        height:165,
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 15,
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
                            "Nutq chiqarish\nmashqlariga xush\nkelibsan!",
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
                        height: size.width*1,
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
                            // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const StartButtonPage()),);
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
                                "BOSHLA!",
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
                                  "BOSHLA!",
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

              ],
            ),
          ),
        ),
      ),
    );  }
}
