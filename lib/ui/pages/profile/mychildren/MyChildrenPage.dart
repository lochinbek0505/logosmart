import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/profile/mychildren/ChildFullInfoPage.dart';

class MyChildrenPage extends StatefulWidget {
  const MyChildrenPage({super.key});

  @override
  State<MyChildrenPage> createState() => _MyChildrenPageState();
}

class _MyChildrenPageState extends State<MyChildrenPage> {

  List<Map<String, dynamic>> children=[
    {"image":"assets/images/wolf.png",
    "name":"Karim Abdullayev",
      "lacation":"Samarkand viloyat, Oq daryo tumani, jarqishloq MFY",
      "age":"3"
    },
    {"image":"assets/images/son_yuzi.png",
      "name":"Mirvohid Shodiyev",
      "lacation":"Samarqan viloyati, Pastdarg'om tumani, Ilm MFY",
      "age":"22"
    },
    {"image":"assets/images/wolf.png",
      "name":"Karim Abdullayev",
      "lacation":"Samarkand viloyat, Oq daryo tumani, jarqishloq MFY",
      "age":"3"
    },
  ];
  @override
  Widget build(BuildContext context) {
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
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        "assets/images/arow_back.png",
                        width: 22,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "Farzandlarim",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (contex,index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14, left: 6, right: 6),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 100,
                              child: Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: AssetImage(children[index]["image"]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          children[index]["name"],
                                          overflow: TextOverflow.ellipsis,

                                          style: TextStyle(
                                            color: Colors.blueGrey.shade800,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          children[index]["lacation"],
                                          textAlign: TextAlign.start,
                                          maxLines: 2,

                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 2,),
                                        Container(width: 70,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            color: Colors.orange.shade50,

                                          ),
                                          child: Center(
                                            child: Text("${children[index]["age"]} yosh",style: TextStyle(
                                                color: Colors.orange.shade600,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13
                                            ),),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 25,),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton(onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>ChildFullInfoPage()));
                              },
                                  style: OutlinedButton.styleFrom(

                                      backgroundColor: Color(0xff20B9E8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),

                                      )
                                  ),
                                  child: Text("To'liq ma'lumot",
                                    style: TextStyle(color: Colors.white,fontSize: 14),
                                  )),
                            ),


                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
