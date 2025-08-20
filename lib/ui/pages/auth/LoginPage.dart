import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();


  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      backgroundColor: Colors.white,
      body: SafeArea(child:Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              Align(
                alignment: Alignment.centerRight,
                child: Text("O'tkazish>",style: TextStyle(
                  color: Color(0xff20B9E8),
                  fontSize: 13,
                ),),
              ),
              SizedBox(height: 10,),
              Text("Ilovaga kirish",style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Colors.black
              ),),
              Text("Logosmart ilovasiga Xush kelibsiz!",style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13
              ),),
              SizedBox(height: 30,),
              Text("Login",style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 13
              ),),
              SizedBox(height: 4,),

              _buildTextField(_login),
              SizedBox(height: 20,),
              Text("Parol",style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 13
              ),),
              SizedBox(height: 4,),

              _buildTextField(
                _password,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon:Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,)
                ),
              ),
              //TODO klaviatura chiqqanda ui ga widgetlar siqmiyabdi yoki Spacerni urniga SizeBox(height:300) misol uchun ishlatib keyin columnni Scrolga urab quyish kerakmi
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(onPressed: ()async{

                  if(_formKey.currentState!.validate()){
                    var data={
                      "Login": _login.text,
                      "Parol": _password.text
                    };

                  }},
                    style: OutlinedButton.styleFrom(

                      backgroundColor: Color(0xff20B9E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),

                      )
                    ),
                    child: Text("Kirish",
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

    );
  }

  Widget _buildTextField(
      TextEditingController controller, {
        bool obscureText = false,
        Widget? suffixIcon,
      }) {
    return TextFormField(
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade800
      ),
      cursorColor: Colors.grey.shade700,
      cursorHeight: 16,
      cursorWidth: 1.5,
      cursorRadius: Radius.zero,
      controller: controller,
      obscureText: obscureText,
      validator:
          (val) =>
      val == null || val.isEmpty ? "to'ldirish shart" : null,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.red),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          suffixIcon: suffixIcon,
        suffixIconColor: Colors.grey.shade600,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300,width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue.shade200,width: 1.8),
        ),


        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
        ),
        errorStyle: TextStyle(
          fontSize: 11,
          height: 0.8,
          color: Colors.red.shade400,
        ),
      ),
    );
  }


}
