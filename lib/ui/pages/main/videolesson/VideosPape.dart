import 'package:flutter/material.dart';

class VideosPage extends StatefulWidget {
  final String title;
  const VideosPage({super.key, required this.title});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return  Scaffold(
      backgroundColor: Color(0xffffffff),
      body: SafeArea(
        child: Column(
          children: [
          SizedBox(height: 25, width: double.infinity),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    "assets/images/arow_back.png",
                    width: 20,
                    color: Color(0xff093e5e),
                  ),
                ),
                SizedBox(width: 24),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 19,
                    color: Color(0xff093e5e),

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
            SizedBox(height: 20,),


            Expanded(



              child: ListView.builder(

                  itemCount: 5,
                  itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16,bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        SizedBox(height: 10,),
                        Text(
                          "${index+1}. Dars nomi",
                          style: TextStyle(
                              color: Color(0xff3c6385),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.2
                          ),
                        ),
                        SizedBox(height: 6,),
                      ],
                    ),
                );
              }),
            )

          ]
        ),
      ),
    );
  }
}
