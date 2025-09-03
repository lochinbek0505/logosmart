import 'package:flutter/material.dart';

class MyExpertPage extends StatefulWidget {
  const MyExpertPage({super.key});

  @override
  State<MyExpertPage> createState() => _MyExpertPageState();
}

class _MyExpertPageState extends State<MyExpertPage> {
  final _formKey = GlobalKey<FormState>();

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/images/eror.png", width: 70, height: 70),

                  SizedBox(height: 16),

                  Text(
                    "Diqqat",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Mutaxassis qo‘shish uchun uning ID raqamini kiriting!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mutaxassis ID raqami",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  TextFormField(
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                    cursorColor: Colors.grey.shade700,
                    cursorHeight: 16,
                    cursorWidth: 1.5,
                    cursorRadius: Radius.zero,
                    validator: (val) => val == null || val.isEmpty
                        ? "Mutaxassis ID raqami kiritilishi shart"
                        : null,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.red),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.blue.shade200,
                          width: 1.8,
                        ),
                      ),

                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.red.shade300,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.8,
                        ),
                      ),
                      errorStyle: TextStyle(
                        fontSize: 11,
                        height: 0.8,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              side: BorderSide(color: Color(0xff20B9E8)),
                            ),
                            child: Text(
                              "Ortga",
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff20B9E8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Tasdiqlash",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
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
                      width: 22,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Mening mutaxassislarim",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.27),
              ImageIcon(
                AssetImage("assets/icons/majesticons_plus.png"),
                size: 64,
                color: Colors.grey.shade900,
              ),
              SizedBox(height: 20),
              Text(
                "Ma'lumot yo'q",
                style: TextStyle(fontSize: 20, color: Colors.grey.shade900),
              ),
              SizedBox(height: 4),
              Text(
                "Hozircha sizning aktiv konsultatsiyangiz yo'q",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    showCustomDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color(0xff20B9E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Mutaxassis qo'shish",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
