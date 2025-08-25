import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/auth/billing/PricingPage.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPage();
}

class _PlanPage extends State<PlanPage> {

  int selectedIndex=-1;




  @override
  Widget build(BuildContext context) {
    var size=MediaQuery.of(context).size;
    return
      Scaffold(
        

        backgroundColor: Colors.white,
        body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/images/backround_daungther.png"),fit: BoxFit.fill)
          ),
          child: SafeArea(child:Padding(
            padding: const EdgeInsets.only(top: 15,left: 15, right: 15),
            child: SingleChildScrollView(
              child: Column(

                children: [
                  SizedBox(height: 30,),
                  Align(
                    alignment: Alignment.center,
                    child: Text("Maxsus taklif",style: TextStyle(
                      color: Colors.grey.shade50,
                      fontWeight: FontWeight.w500,
                      fontSize: 26,
                    ),),
                  ),
                  SizedBox(height: 140,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 2,),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedIndex=0;
                          });
                        },
                        child: Container(
                          width: size.width*0.42,
                          decoration: BoxDecoration(

                            color:selectedIndex==0?Colors.white: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),

                            border: Border.all(width: 1.5,color:selectedIndex==0?Color(0xff20B9E8):Colors.grey.shade200),
                            boxShadow: [
                              selectedIndex==0? BoxShadow(
                                color: Color(0xff9ed6ff),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ):BoxShadow(),

                            ]

                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
                            child: Column(
                              children: [
                                Align(
                                alignment: Alignment.center,
                                child: Text("Oddiy tarif",style: TextStyle(
                                  color:selectedIndex==0? Colors.grey.shade800:Colors.grey.shade600,

                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),),
                              ),
                                SizedBox(height: 14,),

                                Row(
                                children: [
                                  selectedIndex==0?Image.asset("assets/images/green.png",width: 22,height: 22,):Image.asset("assets/images/grey.png",width: 22,height: 22,),
                                  Text(" 5 ta o'yin",style: TextStyle(
                                      color:selectedIndex==0? Colors.grey.shade700:Colors.grey.shade500,
                                    fontSize: 12
                                  ),)

                                ],
                              ),
                                SizedBox(height: 12,),

                                Row(
                                  children: [
                                    selectedIndex==0?Image.asset("assets/images/green.png",width: 22,height: 22,):Image.asset("assets/images/grey.png",width: 22,height: 22,),
                                    Text(" 5 ta video dars",style: TextStyle(
                                        color:selectedIndex==0? Colors.grey.shade700:Colors.grey.shade500,
                                        fontSize: 12
                                    ),)

                                  ],
                                ),
                                SizedBox(height: 12,),

                                Row(
                                  children: [
                                    selectedIndex==0?Image.asset("assets/images/green.png",width: 22,height: 22,):Image.asset("assets/images/grey.png",width: 22,height: 22,),
                                    Text(" Jamiyat",style: TextStyle(
                                        color:selectedIndex==0? Colors.grey.shade700:Colors.grey.shade500,
                                        fontSize: 12
                                    ),)

                                  ],
                                ),
                                SizedBox(height: 14,),

                                Align(
                                                  alignment: Alignment.center,
                                                  child: Text("0 USD",style: TextStyle(
                                                      color:selectedIndex==0? Colors.grey.shade900:Colors.grey.shade700,

                                                      fontSize: 24,
                            fontWeight: FontWeight.w500
                                                  ),),
                                                ),



                                                ],
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedIndex=1;
                          });
                        },
                        child:
                        Container(
                          width: size.width*0.42,
                          decoration: BoxDecoration(
                            color:selectedIndex==1? Color(0xffffffff):Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(width: 1.5,color:selectedIndex==1? Color(0xff20B9E8):Colors.grey.shade200),
                            boxShadow: [

                             selectedIndex==1? BoxShadow(
                                color: Color(0xff9ed6ff),
                                blurRadius: 4,
                                spreadRadius: 2,
                              ):BoxShadow(),
                            ],

                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
                            child: Column(
                              children: [
                                Align(
                                alignment: Alignment.center,
                                child: Text("Siz uchun",style: TextStyle(
                                  color:selectedIndex==1? Colors.grey.shade800:Colors.grey.shade600,

                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),),
                              ),
                                SizedBox(height: 14,),

                                Row(
                                  children: [
                                    selectedIndex==1?Image.asset("assets/images/green.png",width: 22,height: 22,):Image.asset("assets/images/grey.png",width: 22,height: 22,),
                                    SizedBox(width: 4,),
                                    Expanded(
                                      child: Text("50 dan ortiq o'yinlar",style: TextStyle(
                                          color:selectedIndex==1? Colors.grey.shade700:Colors.grey.shade500,
                                          fontSize: 12
                                      ), softWrap: true,),
                                    )

                                  ],
                                ),
                                SizedBox(height: 12,),

                                Row(
                                  children: [
                                    selectedIndex==1?Image.asset("assets/images/green.png",width: 22,height: 22,):Image.asset("assets/images/grey.png",width: 22,height: 22,),
                                    SizedBox(width: 4,),
                                    Expanded(
                                      child: Text("100 dan ortiq video darslar",style: TextStyle(
                                          color:selectedIndex==1? Colors.grey.shade700:Colors.grey.shade500,
                                          fontSize: 12
                                      ), softWrap: true,),
                                    )

                                  ],
                                ),
                                SizedBox(height: 12,),

                                Row(
                                  children: [
                                    selectedIndex==1?Image.asset("assets/images/green.png",width: 22,height: 22,):Image.asset("assets/images/grey.png",width: 22,height: 22,),
                                    SizedBox(width: 4,),
                                    Expanded(
                                      child: Text("5 ta konsultatsiya",style: TextStyle(
                                          color:selectedIndex==1? Colors.grey.shade700:Colors.grey.shade500,
                                          fontSize: 12
                                      ), softWrap: true,),
                                    )

                                  ],
                                ),
                                SizedBox(height: 12,),

                                Row(
                                  children: [
                                    selectedIndex==1?Image.asset("assets/images/green.png",width: 22,height: 22,):Image.asset("assets/images/grey.png",width: 22,height: 22,),
                                    SizedBox(width: 4,),
                                    Expanded(
                                      child: Text("10 dan ortiq marafonlar",style: TextStyle(
                                          color:selectedIndex==1? Colors.grey.shade700:Colors.grey.shade500,
                                          fontSize: 12
                                      ), softWrap: true,),
                                    )

                                  ],
                                ),
                                SizedBox(height: 12,),

                                Row(
                                  children: [
                                    selectedIndex==1?Image.asset("assets/images/green.png",width: 22,height: 22,):Image.asset("assets/images/grey.png",width: 22,height: 22,),
                                    SizedBox(width: 4,),
                                    Expanded(
                                      child: Text("Jamiyat",style: TextStyle(
                                          color:selectedIndex==1? Colors.grey.shade700:Colors.grey.shade500,
                                          fontSize: 12
                                      ), softWrap: true,),
                                    )

                                  ],
                                ),
                                SizedBox(height: 12,),

                                Row(
                                  children: [
                                    selectedIndex==1?Image.asset("assets/images/blue.png",width: 22,height: 22,):Image.asset("assets/images/grey_blue.png",width: 22,height: 22,),

                                    SizedBox(width: 4,),
                                    Expanded(
                                      child: Text("Nutqni chiqarishga 100% kafolat",style: TextStyle(
                                          color:selectedIndex==1? Colors.grey.shade700:Colors.grey.shade500,
                                          fontSize: 12,

                                      ),  softWrap: true,
                                      ),
                                    )

                                  ],
                                ),
                                SizedBox(height: 14,),


                                RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                    text: "100 000",
                                      style: TextStyle(
                                          color:selectedIndex==1? Colors.grey.shade900:Colors.grey.shade700,

                                          fontSize: 24,
                                          fontWeight: FontWeight.w500
                                      ),
                                    children: [
                                      TextSpan(

                                        text: " UZS",
                                        style: TextStyle(
                                            color:selectedIndex==1? Colors.grey.shade900:Colors.grey.shade700,

                                            fontSize: 20,
                                            fontWeight: FontWeight.w400
                                        ),
                                      )
                                    ]
                                  )),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text("200 000 uzs ",style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor:selectedIndex==1? Colors.grey.shade600:Colors.grey.shade500,
                                    decorationThickness: 1.2,
                                    color:selectedIndex==1? Colors.grey.shade600:Colors.grey.shade500,

                                      fontSize: 13,
                                  ),),
                                ),




                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2,)
                    ],
                  ),
                  SizedBox(height: 30,),



                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>PricingPage()));
                    },
                        style: OutlinedButton.styleFrom(

                            backgroundColor: Color(0xff20B9E8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),

                            )
                        ),
                        child: Text("To'lov",
                          style: TextStyle(color: Colors.white,fontSize: 14),
                        )),
                  ),
                  SizedBox(height: 16,),
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
                        child: Text("Yangi hisob yaratish",
                          style: TextStyle(color: Colors.grey.shade800,fontSize: 14),
                        )),
                  ),
                  SizedBox(height: 10,),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Kirish tugmasini bosish orqali siz barcha ", // asosiy qism
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12,height: 1.5),
                      children: [
                        TextSpan(
                          text: "Foydalanish qoidalari ",
                          style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: "va ",
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                        TextSpan(
                          text: "Maxfiylik siyosatiga ",
                          style: TextStyle(color: Colors.black,fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: "rozi bo'lasiz",
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15,)



                ],
              ),
            ),
          ) ),
        ),

      );
  }



}
