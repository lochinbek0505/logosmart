import 'package:flutter/material.dart';

class SpecialistPage extends StatefulWidget {
  const SpecialistPage({super.key});

  @override
  State<SpecialistPage> createState() => _SpecialistPageState();
}

class _SpecialistPageState extends State<SpecialistPage> {
  List<Map<dynamic, dynamic>> camentlist = [
    {
      "image": "assets/images/yarimta_qizcha.png",
      "name": "Abdullayeva Lobar",
      "text":"Logoped — odamlarning til o'rganish, ko'rganish, ko'ngillarini boshqarish va o'z fikrlarini ifoda qilish qobiliyatlarini rivojlantiruvchi mutaxassis.",

      "date":"4 days ago",
      "ontap": 24,
      "number":36,
      "navigation": "",
    },
    {
      "image": "assets/images/yarimta_qizcha.png",
      "name": "Abdullayeva Lobar",
      "text":"Logoped — odamlarning til o'rganish, ko'rganish, ko'ngillarini boshqarish va o'z fikrlarini ifoda qilish qobiliyatlarini rivojlantiruvchi mutaxassis.",

      "date":"4 days ago",
      "ontap": 24,
      "number":36,
      "navigation": "",
    },
    {
      "image": "assets/images/yarimta_qizcha.png",
      "name": "Abdullayeva Lobar",
      "text":"Logoped — odamlarning til o'rganish, ko'rganish, ko'ngillarini boshqarish va o'z fikrlarini ifoda qilish qobiliyatlarini rivojlantiruvchi mutaxassis.",

      "date":"4 days ago",
      "ontap": 24,
      "number":36,
      "navigation": "",
    },
  ];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        "assets/images/arow_back.png",
                        width: 24,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    SizedBox(width: 30),
                    Text(
                      "Abdullayev Muattar",
                      style: TextStyle(
                        fontSize: 21,
                        color: Colors.blueGrey.shade800,
            
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Container(
                  width: size.width,
                  height: size.width * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage("assets/backround/vedio_backround.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Abdullayeva Muattar",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    SizedBox(width: 14),
                    Container(
                      width: 65,
                      height: 29,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.greenAccent.shade400,
                          width: 0.8,
                        ),
                        color: Color(0xffE1F5DF),
                      ),
                      child: Center(
                        child: Text(
                          "Online",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),

                Text(
                  "Shoxmen klinikasi",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8,),

                Row(
                  children: List.generate(5, (starIndex) {
                    var activeBars = 4;
                    Color color = starIndex < activeBars
                        ? Colors.orange.shade500
                        : Colors.grey.shade300;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ImageIcon(
                        AssetImage("assets/icons/star_start.png"),
                        size: 13,
                        color: color,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 30,),


                Text(
                  "Mutaxassisligi:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4,),

                Text(
                  "Logoped, Phd",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                SizedBox(height: 24,),


                Text(
                  "Ish taribasi:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4,),

                Text(
                  "15 yil",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                SizedBox(height: 24,),


                Text(
                  "Yashash manzili:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4,),

                Text(
                  "Farg'ona shahri, Farg'ona viloyati",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                SizedBox(height: 24,),


                Text(
                  "Mutaxassis haqida:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 14,),

                Container(
                  width: size.width,
                  height: size.width * 0.55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage("assets/backround/vedio_backround.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Image.asset("assets/icons/subtract.png",width: 60,height: 60,),
                  ),
                ),
                SizedBox(height: 18,),
            
                Text(
                  "Logoped — odamlarning til o'rganish, ko'rganish, ko'ngillarini boshqarish va o'z fikrlarini ifoda qilish qobiliyatlarini rivojlantiruvchi mutaxassis. Ushbu so'z inglez tilidan 'logoped' so'zidan kelib chiqqan. Logopedlar odatda bolalarning til, so'z, ayrimligi va kommunikatsiya bo'limlarida rivojlantirish uchun ishlaydilar.",
                  maxLines: 12,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Darslar",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    Text(
                      "Barchasini ko'rish",
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.cyan.shade600,
                      ),
                    ),




                  ],
                ),
                SizedBox(height: 20,),
                Container(
                  width: size.width,
                  height: size.width * 0.45,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/backround/img.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow:[
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          spreadRadius: 2,
                          offset: Offset(0, 3),


                        )
                      ]

                  ),
                  child: Center(
                    child: Image.asset("assets/icons/subtract.png",width: 60,height: 60,),
                  ),
                ),
                SizedBox(height: 8,),
                Text(
                  "Dars nomi",
                  style: TextStyle(
                    color: Color(0xff3c6385),
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8,),
                Text("24ta dars 6 soat",style: TextStyle(fontSize: 13.5,color: Colors.grey.shade800,fontWeight: FontWeight.w500),),
                SizedBox(height: 30,),
                Text(
                  "Mutaxassis haqidagi fikrlar",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                SizedBox(height: 24,),
                SizedBox(
                  height: size.width,
                  width: double.infinity,
                  child: ListView.builder(
                      itemCount: camentlist.length,
                      itemBuilder: (context,index){
                    return SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.blueGrey.shade100,
                              backgroundImage: AssetImage(camentlist[index]["image"]),
                            ),
                            SizedBox(width: 10,),
                            Text(camentlist[index]["name"],style: TextStyle(color: Colors.grey.shade900,fontWeight: FontWeight.w500,fontSize: 16),),
                            Spacer(),
                            Container(
                              width: 55,
                              height: 26,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 0.8,
                                ),
                                color: Colors.grey.shade50,
                              ),
                              child: Center(
                                child:Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ImageIcon(
                                      AssetImage("assets/icons/star_start.png"),
                                      size: 14,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 5,),
                                    Text("4",style: TextStyle(fontSize: 12,color: Colors.orange,fontWeight: FontWeight.bold),)
                                  ],
                                ),
                              ),
                            ),

                          ],),
                          SizedBox(height: 16,),
                          Text(camentlist[index]["text"],
                            maxLines: 12,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade400,
                            ),
                          ),
                          SizedBox(height: 8,),
                          Row(
                            children: [
                              Text(camentlist[index]["date"],style: TextStyle(

                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500
                              ),),
                              SizedBox(width: 12,),
                              Icon(Icons.favorite_border,size: 18,color: Colors.red.shade800,weight: 1.5,),
                              SizedBox(width: 4,),
                              Text(camentlist[index]["number"].toString(),style: TextStyle(
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.w600,
                                fontSize: 15
                              ),),

                            ],
                          ),
                          SizedBox(height: 20,),


                        ],
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(onPressed: (){},
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xff20B9E8),width: 1.2),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),


                          )
                      ),
                      child: Text("Xabar jo'natish",
                        style: TextStyle(color: Colors.grey.shade800,fontSize: 14),
                      )),
                ),
                SizedBox(height: 16,),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(onPressed: (){},
                      style: OutlinedButton.styleFrom(

                          backgroundColor: Color(0xff20B9E8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),

                          )
                      ),
                      child: Text("Konsultatsiyaga yozdirish",
                        style: TextStyle(color: Colors.white,fontSize: 14),
                      )),
                ),
                SizedBox(height: 30,)

              ],
            ),
          ),
        ),
      ),
    );
  }
}
