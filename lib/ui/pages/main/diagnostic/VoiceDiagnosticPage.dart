import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/diagnostic/ResaultButtonPage.dart';

class VoiceDiagnosticPage extends StatefulWidget {
  const VoiceDiagnosticPage({super.key});

  @override
  State<VoiceDiagnosticPage> createState() => _VoiceDiagnosticPageState();
}

class _VoiceDiagnosticPageState extends State<VoiceDiagnosticPage> {
  final heights = [4.0, 6.0, 8.0, 11.0, 15.0, 21.0, 28.0, 33.0, 36.0];

  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) =>  ResaultButtonPage()),);
    });

  }


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/backround_toq.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Row(
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
                          Image.asset("assets/icons/namber_o.png", height: 35),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: size.width,
                    height: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(8),
                        value: 0.5,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(heights.length, (index) {
                      var activeBars = 5;
                      Color? color;
                      if (activeBars == 0) {
                        color = Colors.white;
                      } else if (activeBars < heights.length - 1) {
                        color = index < activeBars
                            ? Colors.orange.shade300
                            : Colors.white;
                      } else {
                        color = index < activeBars
                            ? Color(0xff60e04c)
                            : Colors.white;
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 12,
                        height: heights[index],
                        decoration: BoxDecoration(
                          color: color,

                          //isActive ? Colors.green : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 150),
                  SizedBox(
                    width: 130,
                    height: 150,
                    child: Image.asset("assets/images/box.png"),
                  ),
                  SizedBox(height: 160),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 6 + 0),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage("assets/icons/circle.png"),
                        child: Transform.translate(
                          offset: Offset(0, -1),
                          child: Image.asset(
                            "assets/icons/micrafon.png",
                            width: 26,
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
                            "assets/icons/pause.png",
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
      ),
    );
  }
}
