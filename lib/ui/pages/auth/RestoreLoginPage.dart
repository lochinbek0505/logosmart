import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/auth/SmsLoginPage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RestoreLoginPage extends StatefulWidget {
  const RestoreLoginPage({super.key});

  @override
  State<RestoreLoginPage> createState() => _RestoreLoginPageState();
}

class _RestoreLoginPageState extends State<RestoreLoginPage> {
  final phoneMask = MaskTextInputFormatter(
    mask: "## ### ## ##",
    filter: {"#": RegExp(r"[0-9]")},
    type: MaskAutoCompletionType.lazy,
  );

  final _formKey = GlobalKey<FormState>();

  final _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Row(
                    children: [
                      GestureDetector(
                          onTap: (){Navigator.of(context).pop();},
                          child:
                          Image.asset("assets/images/arow_back.png",width: 24,)
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Qayta tiklash",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Logosmart ilovasidagi login yoki parolingizni faqat nomeringiz orqali qayta tiklashingiz mumkin!",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  SizedBox(height: 28),
                  Text(
                    "Telefon raqamingiz",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 4),

                  TextFormField(
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                    keyboardType: TextInputType.number,

                    cursorColor: Colors.grey.shade700,
                    cursorHeight: 16,
                    cursorWidth: 1.5,
                    cursorRadius: Radius.zero,
                    controller: _phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Telefon raqamingizni kiriting";
                      } else if (!RegExp(
                        r'^\d{2}\s\d{3}\s\d{2}\s\d{2}$',
                      ).hasMatch(value)) {
                        return "To‘g‘ri telefon raqam kiriting (+998 90 123 45 67)";
                      }
                      return null;
                    },
                    inputFormatters: [phoneMask],
                    decoration: InputDecoration(
                      prefix: Text("+998 "),
                      floatingLabelBehavior: FloatingLabelBehavior.always,

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
                  SizedBox(height: 20),

                  SizedBox(height: size.height * 0.508),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (builder) => SmsLoginPage(phoneNumber: _phone.text,
                              ),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xff20B9E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Kirish",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Kirish tugmasini bosish orqali siz barcha ",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: "Foydalanish qoidalari ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: "va ",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "Maxfiylik siyosatiga ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: "rozi bo'lasiz",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
}
