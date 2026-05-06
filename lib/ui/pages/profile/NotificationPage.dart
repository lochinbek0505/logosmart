import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String,dynamic>> notification=[
    {"text":"Abdullayeva Lobar 23 fevral soat 16:00 ga onlayn konsultatsiya belgilandi",
    "image":"assets/icons/circle_avatar.png",
      "date":"15 mart"
    },
    {"text":"Abdullayeva Lobar 23 fevral soat 16:00 ga onlayn konsultatsiya belgilandi",
      "image":"assets/icons/circle_avatar.png",
      "date":"20 mart"
    }
  ];
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

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
                      "Bildirishnoma",
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
                  itemCount: notification.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 6,right: 6,bottom: 14),
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              spreadRadius: 3,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: AssetImage(
                                      notification[index]["image"],
                                    ),
                                  ),
                                  SizedBox(width: 20,),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text( notification[index]["text"],
                                          textAlign: TextAlign.start,
                                          maxLines: 6,
                                          overflow: TextOverflow.ellipsis ,
                                          style: TextStyle(
                                              color: Color(0xff276275),
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        Text(notification[index]["date"],style: TextStyle(
                                          color: Colors.grey.shade600,fontSize: 14
                                        ),)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 26),
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
                                  child: Text("Qabul qilish",
                                    style: TextStyle(color: Colors.white,fontSize: 14),
                                  )),
                            ),
                            SizedBox(height: 10,),
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
                                  child: Text("Rad etish",
                                    style: TextStyle(color: Colors.grey.shade800,fontSize: 14),
                                  )),
                            ),                          ],
                        ),
                      ),
                    );
                  }
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
