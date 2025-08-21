import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/auth/NewLoginPage.dart';
import 'package:pinput/pinput.dart';

class SmsLoginPage extends StatefulWidget {
  const SmsLoginPage({super.key});

  @override
  State<SmsLoginPage> createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends State<SmsLoginPage> {

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xfff0f0f0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                GestureDetector(
                    onTap: (){Navigator.of(context).pop();},
                    child: Icon(Icons.arrow_back)),
                SizedBox(height: 16),
                Text(
                  "Telefon raqamini tasdiqlash",
                  style: TextStyle(color: Colors.grey.shade900, fontSize: 20),
                ),
                SizedBox(height: 8),
                RichText(text:TextSpan(
                  text: "***",
                  style: TextStyle(color: Colors.grey.shade700,fontSize: 13,),
                  children: [
                    TextSpan(
                      text: "1234"
                    ),
                    TextSpan(
                      text: " raqamli telefonigizga tasdiqlash kodi yuborildi"
                    )
                  ]
                )),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Pinput(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Kod kiriting!";
                        } else if(value.length<5){
                          return "Kodni to'liq kiriting!";
                        }

                        else if (value != "12345") {
                          return "Noto‘g‘ri kod!";
                        }
                        return null; // ✅ to‘g‘ri bo‘lsa null qaytariladi
                      },
                      length: 5,

                      errorPinTheme: PinTheme(
                          textStyle: TextStyle(
                            fontSize: 18,
                          ),

                          width: 50,
                          height: 52,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade300)
                          )
                      ),
                      errorTextStyle: TextStyle(
                        color: Colors.red.shade300,
                        fontSize: 13,
                      ),
                      defaultPinTheme: PinTheme(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade800,
                        ),
                        width: 50,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300)
                        )
                      ),

                      focusedPinTheme: PinTheme(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade800,
                        ),

                        width: 50,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xff20B9E8), width: 1.2),
                        ),
                      ),


                      submittedPinTheme: PinTheme(
                        textStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade800,
                        ),

                        width: 50,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white, // kiritilgandan keyin fon rangi
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xff20B9E8), width: 1.2),
                        ),
                      ),

                    ),
                  ),
                ),
                
                SizedBox(height: 16,),
                //TODO bu yer yakunlangani yuq
                Align(alignment: Alignment.center,
                child: Text("data"),
                ),


                SizedBox(height: size.height * 0.562),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: ()  {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>NewLoginPage()));
                      }

                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xff20B9E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Tasdiqlash",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
