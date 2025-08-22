import 'package:flutter/material.dart';
import 'package:logosmart/ui/pages/auth/signup/CompletePage.dart';
import 'package:logosmart/ui/pages/auth/register/RegistrationPage.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _login = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void showLoginDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 8,
              right: 12,
              left: 20,
              bottom: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xff20B9E8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(Icons.close, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ),
                ),

                // Warning icon
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/images/eror.png",
                    width: 80,
                    height: 80,
                  ),
                ),
                SizedBox(height: 25),

                // Title
                Text(
                  "Parol uchun quyidagilar muhim:",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                Text("  • A-Z katta harflar", style: TextStyle(fontSize: 13)),
                SizedBox(height: 4),
                Text("  • 1231309 raqamlar", style: TextStyle(fontSize: 13)),
                SizedBox(height: 4),
                Text("  • a-z kichik harflar", style: TextStyle(fontSize: 13)),
                SizedBox(height: 4),
                Text(
                  "  • kamida 8 ta belgilar",
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 10,),
              ],
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
                    "Hisobni qayta yaratish",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 20),
                  ),

                  SizedBox(height: 25),

                  Text(
                    "Login",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  _buildTextField(_login, "Login"),

                  SizedBox(height: 20),
                  Text(
                    "Parol",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 5),
                  _buildTextField(
                    _password,
                    "Parol",
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Parolni tasdiqlang",
                    style: TextStyle(color: Colors.grey.shade900, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  TextFormField(
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                    cursorColor: Colors.grey.shade700,
                    cursorHeight: 16,
                    cursorWidth: 1.5,
                    cursorRadius: Radius.zero,
                    controller: _confirmPassword,
                    obscureText: _obscureConfirm,

                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Parolni tasdiqlang to'ldirilishi shart";
                      } else if (_password.text != _confirmPassword.text) {
                        return "Parollar mos emas!";
                      }
                      return null;
                    },

                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.red),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 12,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      suffixIconColor: Colors.grey.shade600,
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

                  SizedBox(height: size.height * 0.38),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final password = _password.text;

                          if (RegExp(r'[A-Z]').hasMatch(password) &&
                              RegExp(r'[a-z]').hasMatch(password) &&
                              RegExp(r'[0-9]').hasMatch(password) &&
                              password.length >= 8) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (builder) => RegistrationPage(),
                              ),
                            );
                          } else {
                            showLoginDialog();
                          }
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
        labelStyle: TextStyle(color: Colors.red),
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
}
