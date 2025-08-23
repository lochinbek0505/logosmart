import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/auth/signup/CompletePage.dart';

class ChildRegisterPage extends StatefulWidget {
  const ChildRegisterPage({super.key});

  @override
  State<ChildRegisterPage> createState() => _ChildRegisterPageState();
}

class _ChildRegisterPageState extends State<ChildRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();

  bool onPresses=false;

  int? agem;
  int selectedImage=-1;

  @override
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, right: 15, left: 15),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      "assets/images/arow_back.png",
                      width: 24,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Farzandingiz",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 20),
                  ),

                  SizedBox(height: 22),
                  Text(
                    "Farzandingizni jinsini tanlang",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 14),
                  ),

                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedImage=0;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(1.2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:selectedImage==0? Color(0xff20B9E8):Colors.grey.shade300,
                          ),
                          child: Container(
                            width: 105,
                            height: 105,
                            decoration: BoxDecoration(
                        
                              shape: BoxShape.circle,
                              color: Colors.grey.shade50,
                              image: DecorationImage(image: AssetImage("assets/images/son_yuzi.png"),alignment: Alignment.bottomCenter,fit: BoxFit.scaleDown)
                            ),
                            child:selectedImage==0? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  bottom: 2,
                                  right: 10,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    
                                    decoration: BoxDecoration(
                                        color: Color(0xff20B9E8),
                        
                                        shape: BoxShape.circle
                                    ),
                                    child: Center(
                                      child: Icon(Icons.check,size: 12,color: Colors.white,),
                        
                                    ),
                                  ),
                                ),
                              ],
                            ):SizedBox(),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            selectedImage=1;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(1.2),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:selectedImage==1? Color(0xff20B9E8):Colors.grey.shade300
                          ),
                          child: Container(
                            width: 105,
                            height: 105,
                            
                            decoration: BoxDecoration(
                        
                                shape: BoxShape.circle,
                                color: Colors.grey.shade50,
                                image: DecorationImage(image: AssetImage("assets/images/qizchani_yuzi.png"),alignment: Alignment.bottomCenter,fit: BoxFit.scaleDown)
                            ),
                            child: selectedImage==1? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  bottom: 2,
                                  right: 10,
                                  child: Container(
                                    width: 16,
                                    height: 16,

                                    decoration: BoxDecoration(
                                        color: Color(0xff20B9E8),

                                        shape: BoxShape.circle
                                    ),
                                    child: Center(
                                      child: Icon(Icons.check,size: 12,color: Colors.white,),

                                    ),
                                  ),
                                ),
                              ],
                            ):SizedBox(),
                          ),
                        ),
                      )

                    ],),
                  ),
                  //TODO: bir narsa qilmoqchi edim ammo uxshatolmadim
                  onPresses==true?Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text("Jinsini tanlang",style: TextStyle(

                      fontSize: 11,
                      height: 0.8,
                      color: Colors.red.shade400,
                    ),),
                  ):SizedBox(),
                  SizedBox(height: 20,),


                  Text(
                    "Farzandingizni ismi",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  _buildTextField(_firstName, "Farzandingizni ismi"),

                  SizedBox(height: 20),


                  Text(
                    "Yoshi",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 5),
                  _ageDropdown(
                    hind: "Yoshi",
                    value: agem,
                    items: [],
                    onChanged: (val) {
                      setState(() {
                        val = agem;
                      });
                    },
                  ),
                  SizedBox(height: 24,),
                  Text(
                    "Rasm yuklang (ixtiyoriy)",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 6),


               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                child: DottedBorder(





                  options: RoundedRectDottedBorderOptions(
                    radius: Radius.circular(10),
                    dashPattern: [16,10],






                    strokeWidth: 1.5,

                    stackFit: StackFit.passthrough,
                    color: Colors.grey.shade400,

                  ),


                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child:  Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff20B9E8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child:Text("+",style: TextStyle(
                            color: Colors.white,fontSize: 20
                          ),)
                        ),
                      ),
                    ),
                  ),

                ),
              ),



              SizedBox(height: size.height * 0.08),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>CompletePage()));

                        }
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
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    hint, {
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
      cursorColor: Colors.grey.shade700,
      cursorHeight: 16,
      cursorWidth: 1.5,
      cursorRadius: Radius.zero,
      controller: controller,
      obscureText: obscureText,

      validator: (val) {
        if (val == null || val.isEmpty) {
          return "$hint to'ldirilishi shart!";
        }
        return null;
      },

      decoration: InputDecoration(
        isDense: true,

        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 12),

        suffixIcon: suffixIcon,
        suffixIconColor: Colors.grey.shade600,
        filled: true,
        fillColor: Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue.shade200, width: 1.8),
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

  Widget _ageDropdown<T>({
    required hind,
    required T? value,
    required List<Map<String, dynamic>> items,
    required void Function(T?) onChanged,
  }) {
    var size = MediaQuery.of(context).size;

    return DropdownButtonFormField2<T>(
      style: TextStyle(fontSize: 14, color: Colors.grey.shade800),

      value: value,
      items: [
        for (int i = 1; i <= 200; i++)
          DropdownMenuItem(value: i as T, child: Text("$i")),
      ],
      onChanged: onChanged,

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),

        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 12),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.blue.shade200, width: 1.8),
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
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 8),
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 20),
          ],
        ),
        maxHeight: 250,
        width: size.width * 0.8,

        elevation: 4,
        offset: Offset(size.width * 0.1, 0),
      ),

      validator: (val) => val == null ? "$hind tanlanishi shart" : null,
    );
  }
}
