import 'package:flutter/material.dart';

import '../specialist/SpecialistPage.dart';


class PageViewOne extends StatefulWidget {
  const PageViewOne({super.key});

  @override
  State<PageViewOne> createState() => _PageViewOneState();
}

class _PageViewOneState extends State<PageViewOne> {
  List<Map<dynamic, dynamic>> societyinfo = [
    {
      "image": "assets/images/yarimta_qizcha.png",
      "name": "Abdullayeva Muattar",
      "text": "Oliy ma'lumotli logaped",
      "year": 15,
      "number": 24,
      "level": 2,
      "navigation": "",
    },
    {
      "image": "assets/images/yarimta_qizcha.png",
      "name": "Abdullayeva Muattar",
      "text": "Oliy ma'lumotli logaped",
      "year": 15,
      "number": 24,
      "level": 3,
      "navigation": "",
    },
    {
      "image": "assets/images/yarimta_qizcha.png",
      "name": "Abdullayeva Muattar",
      "text": "Oliy ma'lumotli logaped",
      "year": 15,
      "number": 24,
      "level": 1,
      "navigation": "",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: societyinfo.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 12,
            left: 6,
            right: 6,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (builder) => SpecialistPage(),
                ),
              );
            },
            child: Container(
              height: 126,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      image: DecorationImage(
                        image: AssetImage(
                          societyinfo[index]["image"],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        societyinfo[index]["name"],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      Text(
                        societyinfo[index]["text"],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 90,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(20),
                              color: Color(0xffd9F6FB),
                            ),
                            child: Center(
                              child: Text(
                                "${societyinfo[index]["year"]} yil tajriba",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                  color: Color(0xff093e5e),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 90,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(20),
                              color: Color(0xffd9F6FB),
                            ),
                            child: Center(
                              child: Text(
                                "+${societyinfo[index]["number"]} miozlar",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                  color: Colors
                                      .blueGrey
                                      .shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (
                            starIndex,
                            ) {
                          var activeBars =
                          societyinfo[index]["level"];
                          Color color =
                          starIndex < activeBars
                              ? Colors.orange.shade500
                              : Colors.grey.shade300;
                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            child: ImageIcon(
                              AssetImage(
                                "assets/icons/star_start.png",
                              ),
                              size: 13,
                              color: color,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
