import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/society/widget/PageViewOne.dart';
import 'package:logosmart/ui/pages/society/widget/PageViewThree.dart';
import 'package:logosmart/ui/pages/society/widget/PageViewTwo.dart';

class SocietyPage extends StatefulWidget {
  const SocietyPage({super.key});

  @override
  State<SocietyPage> createState() => _SocietyPageState();
}

class _SocietyPageState extends State<SocietyPage> {
  List<String> name=[
    "Mutaxassislar",
    "Tashkilotlar",
    "Jamiyat"

  ];


  var itemCount = 1;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  children: [
                    Text(

                      "Jamiyat",style: TextStyle(
                        color: Colors.blueGrey.shade800,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    ImageIcon(
                      AssetImage("assets/icons/search.png"),
                      size: 20,
                      color: Colors.blueGrey.shade800,
                    ),
                    SizedBox(width: 16),
                    ImageIcon(
                      AssetImage("assets/icons/vector.png"),
                      size: 20,
                      color: Colors.blueGrey.shade800,
                    ),
                    SizedBox(width: 16),
                    ImageIcon(
                      AssetImage("assets/icons/notification.png"),
                      size: 20,
                      color: Colors.blueGrey.shade800,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Container(
                  width: size.width,
                  height: 48,
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [

                      AnimatedAlign(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: itemCount == 1
                            ? Alignment.centerLeft
                            : itemCount == 2
                            ? Alignment.center
                            : Alignment.centerRight,
                        child: Container(
                          width: (size.width - 4) / 3 - 12,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(0xff20B9E8),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  itemCount = 1;
                                });
                                _pageController.animateToPage(
                                  0,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Center(
                                child: Text(
                                  "Mutaxassislar",
                                  style: TextStyle(
                                    color: itemCount == 1
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  itemCount = 2;
                                });
                                _pageController.animateToPage(
                                  1,
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Center(
                                child: Text(
                                  "Tashkilotlar",
                                  style: TextStyle(
                                    color: itemCount == 2
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  itemCount = 3;
                                });
                                _pageController.animateToPage(
                                  2,
                                  duration: Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Center(
                                child: Text(
                                  "Jamiyat",
                                  style: TextStyle(
                                    color: itemCount == 3
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: 3,

                  itemBuilder: (ctx, i) {
                    switch (i) {
                      case 0:
                        return PageViewOne();
                      case 1:
                        return PageViewTwo();
                      case 2:
                        return PageViewThree();

                      default:
                        return SizedBox();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
