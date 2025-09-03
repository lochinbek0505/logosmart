import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/main/MainPage.dart';
import 'package:logosmart/ui/pages/profile/mychildren/MyChildrenPage.dart';
import 'package:logosmart/ui/pages/profile/myexpert/MyExpertPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return  Scaffold(
      backgroundColor: Color(0xffffffff),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text("Profil",style: TextStyle(color: Colors.blueGrey.shade800,fontSize: 22,fontWeight: FontWeight.w600),),
              ),
              SizedBox(height: 40,),
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blueGrey.shade200,
                  backgroundImage: AssetImage("assets/images/yarimta_qizcha.png"),
                ),
              ),
              SizedBox(height: 12,),
              Align(
                alignment: Alignment.center,
                child: Text("Abdusattorova Lobarxon",style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.blueGrey.shade800
                ),),
              ),
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(width: size.width,height: 1,color: Colors.grey.shade300,),
              ),
              SizedBox(height: 30,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: (){
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        width: size.width,
                        height: 52,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.shade200,
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: Offset(0, 2)
                              )
                            ]
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Balans : 99 000 000 so'm",

                            style: TextStyle(

                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color:  Color(0xff20B9E8),
                          ),),
                        ),
                      ),
                    ),
                  ),

              SizedBox(height: 25,),
              _widget(title: "Mening mutaxassislarim", icon: "assets/icons/plus.png", navigation: MyExpertPage()),
              _widget(title: "Farzandlarim", icon: "assets/icons/user.png", navigation: MyChildrenPage()),
              _widget(title: "Mening ma'lumotlarim", icon: "assets/icons/user.png", navigation: MainPage()),
              _widget(title: "Til", icon: "assets/icons/language.png", navigation: MainPage()),
              _widget(title: "Sozlamalar", icon: "assets/icons/settings.png", navigation: MainPage()),
              _widget(title: "Bildirishnoma", icon: "assets/icons/qungiroq.png", navigation: MainPage()),
              SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: (){
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 11),
                        width: size.width,
                        height: 52,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Center(
                          child: Row(
                              children:
                              [
                                CircleAvatar(backgroundColor:  Colors.red.shade300,
                                  radius: 15,
                                  child: Center(
                                    child: Image.asset("assets/icons/delete.png",width: 16,height: 16,),
                                  ),
                                ),
                                SizedBox(width: 12,),
                                Text("Hisobni o'chirish",style: TextStyle(
                                    color: Colors.red.shade600,fontSize: 13.5,fontWeight: FontWeight.w500
                                ),),]
                          ),
                        ),

                      ),
                    ),
                  ),

              SizedBox(height: 50,),




            ],
          ),
        ),
      )),
    );
  }
  Widget _widget({
  required  String title,
 required final icon,
 required final navigation}){
    var size = MediaQuery.of(context).size;


    return             Padding(
      padding: const EdgeInsets.only(bottom:8 ,left: 6,right: 6),
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>navigation));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 11),
          width: size.width,
          height: 52,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade200,
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 2)
                )
              ]
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    children:
                    [
                      CircleAvatar(backgroundColor:  Color(0xff20B9E8),
                        radius: 15,
                        child: Center(
                          child: Image.asset(icon,width: 16,height: 16,),
                        ),
                      ),
                      SizedBox(width: 12,),
                      Text(title,style: TextStyle(
                          color: Colors.blueGrey.shade700,fontSize: 13.5,fontWeight: FontWeight.w500
                      ),),]
                ),
                Icon(Icons.arrow_forward_ios,size: 15,color: Colors.blueGrey.shade800,),

              ],
            ),
          ),
        ),
      ),
    )
    ;
  }
}
