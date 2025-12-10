import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/videolesson/VideosPape.dart';

class VideoLessonsPage extends StatefulWidget {
  const VideoLessonsPage({super.key});

  @override
  State<VideoLessonsPage> createState() => _VideoLessonsPageState();
}

class _VideoLessonsPageState extends State<VideoLessonsPage> {
  List<Map<dynamic, dynamic>> vedioLesson = [
    {
      "image": "assets/backround/vedio_backround.png",
      "text": "Ilk nutqni rivojlantirish",
      "number": 58,
    },
    {
      "image": "assets/backround/vedio_backround.png",
      "text": "Tovushlar bo'yicha mashg'ulotlar",
      "number": 24,
      "navigation": "",
    },
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
      backgroundColor: Color(0xfff0f0f0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
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
                        alignment: itemCount == 1 ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          width: (size.width - 4) / 2-8,
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
                                );                            },
                              child: Center(
                                child: Text(
                                  "Darslarim",
                                  style: TextStyle(
                                    color: itemCount == 1 ? Colors.white : Colors.black,
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
                                );                            },
                              child: Center(
                                child: Text(
                                  "Qoralamalar",
                                  style: TextStyle(
                                    color: itemCount == 2 ? Colors.white : Colors.black,
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

              SizedBox(height: 2),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),

                  itemCount: 2,

                  itemBuilder: (ctx, i) {
                    switch (i) {
                      case 0:
                        return ListView.builder(
                          itemCount: vedioLesson.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12,right: 6,left: 6),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (builder) => VideosPage(
                                        title: vedioLesson[index]["text"],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 4,
                                        spreadRadius: 2,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: size.width,
                                        height: size.width * 0.4,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                              vedioLesson[index]["image"],
                                            ),
                                            fit: BoxFit.fill,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        vedioLesson[index]["text"],
                                        style: TextStyle(
                                          color: Colors.grey.shade900,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Container(
                                        width: 82,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Color(0xffd9F6FB),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${vedioLesson[index]["number"]} ta dars",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xff093e5e),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      case 1:
                        return SizedBox();
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
