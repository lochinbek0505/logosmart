import 'package:flutter/material.dart';

class PageViewThree extends StatefulWidget {
  const PageViewThree({super.key});

  @override
  State<PageViewThree> createState() => _PageViewThreeState();
}

class _PageViewThreeState extends State<PageViewThree> {
  List<Map<dynamic, dynamic>> datalist = [
    {
      "image": "assets/images/yarimta_qizcha.png",
      "name": "Abdullayeva Lobar",
      "text":
      "Logoped — odamlarning til o'rganish, ko'rganish, ko'ngillarini boshqarish va o'z fikrlarini ifoda qilish qobiliyatlarini rivojlantiruvchi mutaxassis.",

      "date": "4 days ago",
      "ontap": 24,
      "number": 36,
      "navigation": "",
    },
    {
      "image": "assets/images/yarimta_qizcha.png",
      "name": "Abdullayeva Lobar",
      "text":
      "Logoped — odamlarning til o'rganish, ko'rganish, ko'ngillarini boshqarish va o'z fikrlarini ifoda qilish qobiliyatlarini rivojlantiruvchi mutaxassis. Ushbu so'z inglez tilidan 'logoped' so'zidan kelib chiqqan. Logopedlar odatda bolalarning til, so'z, ayrimligi va kommunikatsiya bo'limlarida rivojlantirish uchun ishlaydilar.",

      "date": "4 days ago",
      "ontap": 24,
      "number": 36,
      "backround_image": "assets/backround/vedio_backround.png",

      "navigation": "",
    },
    {
      "image": "assets/images/yarimta_qizcha.png",
      "name": "Abdullayeva Lobar",
      "text":
      "Logoped — odamlarning til o'rganish, ko'rganish, ko'ngillarini boshqarish va o'z fikrlarini ifoda qilish qobiliyatlarini rivojlantiruvchi mutaxassis.",

      "date": "4 days ago",
      "ontap": 24,
      "number": 36,
      "navigation": "",
    },
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ListView.builder(
      itemCount: datalist.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                    Colors.blueGrey.shade100,
                    backgroundImage: AssetImage(
                      datalist[index]["image"],
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: size.width - 100,
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        SizedBox(width: 10),
                        Text(
                          datalist[index]["name"],
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),

                        datalist[index]["backround_image"] !=
                            null
                            ? Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 5,
                          ),
                          child: Container(
                            width: double.infinity,
                            height: size.width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                              image: DecorationImage(
                                image: AssetImage(
                                  datalist[index]["backround_image"],
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                            : SizedBox(),

                        SizedBox(height: 5),
                        Text(
                          datalist[index]["text"],
                          maxLines: 12,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade400,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 21,
                              color: Colors.red.shade800,
                              weight: 1.5,
                            ),
                            SizedBox(width: 12),
                            ImageIcon(
                              AssetImage(
                                "assets/icons/samalyot.png",
                              ),
                              color: Colors.black,
                              size: 18,
                            ),

                            SizedBox(width: 12),
                            ImageIcon(
                              AssetImage(
                                "assets/icons/coment.png",
                              ),
                              color: Colors.black,
                              size: 18,
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              "53 javob  ",

                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            Icon(Icons.circle,size: 8,color: Colors.grey.shade400,),
                            Text(
                              "  153 yoqdi",

                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
