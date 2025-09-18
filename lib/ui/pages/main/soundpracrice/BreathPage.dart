import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/VideoPage.dart';

class BreathPage extends StatefulWidget {
  const BreathPage({super.key});

  @override
  State<BreathPage> createState() => _BreathPageState();
}

class _BreathPageState extends State<BreathPage> {
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) =>  VideoButtonPage()),);
    });

  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return  Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/backround/backround_puff.png"),fit: BoxFit.fill)
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(child: Image.asset("assets/images/puff.png",height: size.width*1.35,width: size.width*0.65,fit: BoxFit.fill,)),
            ),
            Column(
              children: [
                Spacer(),
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
                SizedBox(height: 40,)

              ],
            )
          ],
        ),
      ),
    );
  }
}
