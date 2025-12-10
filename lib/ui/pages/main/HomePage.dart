import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/main/diagnostic/DiagnosticPage.dart';
import 'package:logosmart/ui/pages/main/soundpracrice/AlphabetPage.dart';
import 'package:logosmart/ui/pages/main/videolesson/VideoLessonsPage.dart';
import 'package:logosmart/ui/theme/AppColors.dart';
import 'package:shiny_striped_progress_bar/shiny_striped_progress_bar.dart';

import 'firstspeech/StartSpeechPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> cards = [
    {
      "title": "Ilk nutqni\nrivojlantirish",
      "image": "assets/images/mashgulot_bad.png",
      "mainColor": Color(0xffebb6ae),
      "text": "4+ yosh",
      "page": StartSpeechPage(),
    },
    {
      "title": "Tovushlar\ntalaffuzini\nrivojlantirish",
      "image": "assets/images/mashgulot_son.png",
      "mainColor": Color(0xff20B9E8),
      "text": "3-5 yosh",
      "page": AlphabetPage(),
    },
    {
      "title": "Video\nmashg'ulotlar",
      "image": "assets/images/mashgulot_nice.png",
      "mainColor": Colors.blueGrey.shade700,
      "text": "0-5 yosh",
      "page": VideoLessonsPage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xffd5eef7),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              collapsedHeight: 80,
              backgroundColor: Color(0xffd5eef7),
              title: SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Assalomu alaykum",
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            color: AppColors.main_blue_900,
                          ),
                        ),
                        Text(
                          "Lobarxon !",
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            color: AppColors.main_blue_900,
                          ),
                        ),
                      ],
                    ),
                    ImageIcon(
                      AssetImage("assets/icons/notification.png"),
                      size: 20,
                      color: AppColors.main_blue_900,
                    ),
                  ],
                ),
              ),
            ),
            SliverAppBar(
              toolbarHeight: 110,

              backgroundColor: Color(0xffd5eef7),
              automaticallyImplyLeading: false,

              pinned: true,
              title: Container(
                width: size.width,
                // height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 26,

                        child: CircleAvatar(
                          backgroundColor: Color(0xff20B9E8),
                          radius: 11,
                          child: Transform.translate(
                            offset: Offset(0.9, 0),
                            child: ImageIcon(
                              AssetImage("assets/icons/right_back.png"),
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "So'ngi harakat",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          SizedBox(height: 10),

                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: AssetImage(
                                  "assets/icons/circle_avatar.png",
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "01. Nutqni rivojlantirish va...",
                                    style: TextStyle(
                                      color: Colors.grey.shade900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  SizedBox(
                                    width: size.width - 143,
                                    height: 10,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: ShinyStripedProgressBar(
                                        progressColor: AppColors.orange_200,
                                        stripeColor: AppColors.orange_500,
                                        targetProgress: .5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 8,
                  top: 20,
                ),
                child: Container(
                  width: double.infinity,
                  height: 152,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage("assets/images/diagnostika.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          top: 14,
                          bottom: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ekpress-\ndiagnostika",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 14),

                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (builder) => DiagnosticPage(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 110,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.orange.shade400,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Boshlash",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Card(
                                        elevation: 2,
                                        shadowColor: Colors.orange.shade800,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.orange,
                                          radius: 11,
                                          child: Transform.translate(
                                            offset: Offset(0.9, 0),
                                            child: ImageIcon(
                                              AssetImage(
                                                "assets/icons/right_back.png",
                                              ),
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Spacer(),
                    ],
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: cards.length,
                (contex, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(cards[index]["image"]),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Row(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              top: 14,
                              bottom: 14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cards[index]["title"],
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade800,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 12),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (builder) =>
                                            cards[index]["page"],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 110,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: cards[index]["mainColor"],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Boshlash",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 11,
                                            child: Transform.translate(
                                              offset: Offset(0.9, 0),
                                              child: ImageIcon(
                                                AssetImage(
                                                  "assets/icons/right_back.png",
                                                ),
                                                size: 12,
                                                color:
                                                    cards[index]["mainColor"],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 67,
                                      height: 27,
                                      decoration: BoxDecoration(
                                        color: Color(0xff60e04c),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "40 ta o'yin",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Container(
                                      width: 67,
                                      height: 27,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade300,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          cards[index]["text"],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
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
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
