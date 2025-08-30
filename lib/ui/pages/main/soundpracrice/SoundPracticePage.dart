import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/PinwheelPage.dart';

class SoundPracticePage extends StatefulWidget {
  const SoundPracticePage({super.key});

  @override
  State<SoundPracticePage> createState() => _SoundPracticePageState();
}

class _SoundPracticePageState extends State<SoundPracticePage> {

  final List<Map<String, dynamic>> alphabet=[
    {
      "alphabet":"assets/alphabet/r.png",
      "text":"R",
      "number":32

    },
    {
      "alphabet":"assets/alphabet/l.png",
      "text":"L",
      "number":32

    },
    {
      "alphabet":"assets/alphabet/s.png",
      "text":"S",
      "number":32

    },
    {
      "alphabet":"assets/alphabet/y.png",
      "text":"Y",
      "number":32

    },
    {
      "alphabet":"assets/alphabet/r.png",
      "text":"R",
      "number":32

    },
  ];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,

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
                boxShadow: [],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  SizedBox(height: 40, width: double.infinity),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                            "assets/images/arow_back.png",
                            width: 24,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(width: 30),
                        Text(
                          "Tovush mashqlari",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blueGrey.shade800,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      itemCount: alphabet.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 7,
                            horizontal: 6
                          ),
                          child:                   Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),

                            width: size.width,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              image: DecorationImage(
                                image: AssetImage(
                                  "assets/backround/bacround_sound.png",
                                ),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(14),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueGrey.shade200.withOpacity(0.5),
                                  spreadRadius: 4,

                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(2),

                                      width: 74,
                                      height: 74,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xffb5e9f7),
                                            Color(0xff5ad4f2),
                                          ],
                                          end: Alignment.bottomCenter,
                                          begin: Alignment.topCenter,
                                        ),
                                      ),
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(35),
                                          color: Colors.cyan.shade50,
                                        ),
                                        child: Center(
                                          child: Image(
                                            image: AssetImage(alphabet[index]["alphabet"]),
                                            height: 46,
                                            width: 46,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${alphabet[index]["text"]} tovushini\nrivojlantirish",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Color(0xff093e5e),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: (){
                                            Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>PinwheelPage()));
                                          },
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: AssetImage(
                                                  "assets/icons/circle.png",
                                                ),
                                                radius: 18,
                                                child: Transform.translate(
                                                  offset: Offset(1, -1),
                                                  child: Image(
                                                    image: AssetImage(
                                                      "assets/icons/play.png",
                                                    ),
                                                    width: 15,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                "Boshlash",
                                                style: TextStyle(
                                                  color: Color(0xff20B9E8),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    width: 100,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color(0xffd9F6FB),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${alphabet[index]["number"]} ta mashg'ulot",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff093e5e),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
