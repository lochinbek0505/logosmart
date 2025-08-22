import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/auth/register/ChildRegisterPage.dart';

class CompletePage extends StatefulWidget {
  const CompletePage({super.key});

  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return  Scaffold(

      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Color(0xffccefff),
          image: DecorationImage(image: AssetImage("assets/images/succers.png"),fit: BoxFit.fitWidth,alignment: Alignment.topCenter),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                SizedBox(height: 15),
                GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child:
                        Image.asset("assets/images/arow_back.png",width: 24,)
                    )),



                SizedBox(height: size.width*0.95),
                Text("Muvaffaqiyatli",style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Colors.black            ),),
                Text("Muavaffaqiyatli bajarildi",style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13
                ),),
                Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>ChildRegisterPage()));
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xff20B9E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Keyingi",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),

      ),
    );
  }
}
