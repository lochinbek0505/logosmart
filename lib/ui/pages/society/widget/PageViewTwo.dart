import 'package:flutter/material.dart';

class PageViewTwo extends StatefulWidget {
  const PageViewTwo({super.key});

  @override
  State<PageViewTwo> createState() => _PageViewTwoState();
}

class _PageViewTwoState extends State<PageViewTwo> {
  List<Map<dynamic, dynamic>> farmlist = [
    {
      "image": "assets/backround/backround_hospital.png",
      "name": "Medicana hospital",
      "manzil": "Yunusobod tuman, 12 kvartal",
      "level": 2,
      "navigation": "",
    },
    {
      "image": "assets/backround/backround_hospital.png",
      "name": "Medicana hospital",
      "manzil": "Yunusobod tuman, 12 kvartal",
      "level": 3,
      "navigation": "",
    },
    {
      "image": "assets/backround/backround_hospital.png",
      "name": "Medicana hospital",
      "manzil": "Yunusobod tuman, 12 kvartal",
      "level": 4,
      "navigation": "",
    },
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ListView.builder(
        itemCount: farmlist.length,
        itemBuilder: (context,index){
          return Padding(
            padding: const EdgeInsets.only(left: 6,right: 6,bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],


                  color: Colors.white
              ),
              padding: EdgeInsets.only(left: 10,right: 10,bottom: 16,top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: size.width*0.4,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: AssetImage(farmlist[index]["image"]),fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 12,),

                  Text(farmlist[index]["name"],style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),),
                  SizedBox(height: 12,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (
                        starIndex,
                        ) {
                      var activeBars =
                      farmlist[index]["level"];
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
                  SizedBox(height: 12,),

                  Text(farmlist[index]["manzil"],style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500
                  ),)
                ],
              ),
            ),
          );
        });
  }
}
