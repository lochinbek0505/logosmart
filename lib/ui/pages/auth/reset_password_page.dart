import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/login_page.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/auth/widgets/input_form_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ResetPasswordPage extends StatefulWidget {
  String phone;

  ResetPasswordPage({super.key, required this.phone});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late TextEditingController _phoneController;
  late TextEditingController _passwordInitController;

  late TextEditingController _passwordVerifyController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordInitController = TextEditingController();
    _passwordVerifyController = TextEditingController();
    _phoneController.text = "+998";
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.w),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // Ekran balandligidan kam bo'lmagan joy egallashi uchun
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: Form(
              key: _formKey,
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: Text(
                        "Hisobni qayta yaratish",
                        style: GoogleFonts.nunito(
                          color: AppColors.grey_900,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 36.h),

                    InputFormWidget(
                      controller: _passwordInitController,
                      label: "Parol",
                      isPassword: true,
                      validator: (v) {
                        if (v!.isEmpty || v == null)
                          return "Parol kiritilishi shart";
                        if (v.length < 8)
                          return "Parol kamida 8 ta belgidan iborat bo'lishi kerak";
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    InputFormWidget(
                      controller: _passwordVerifyController,
                      label: "Parolni tasdiqlang",
                      isPassword: true,
                      validator: (v) {
                        if (v!.isEmpty || v == null)
                          return "Parol kiritilishi shart";

                        if (v != _passwordInitController.text)
                          return "Parollar mos emas";
                        if (v.length < 8)
                          return "Parol kamida 8 ta belgidan iborat bo'lishi kerak";

                        return null;
                      },
                    ),

                    const Spacer(),

                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.main_blue_600,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            // Loading vaqtida rang xiralashadi
                            disabledBackgroundColor: AppColors.main_blue_600.withOpacity(0.7),
                          ),
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              var payload = {
                                "phoneNumber": widget.phone,
                                "newPassword": _passwordInitController.text,
                              };
                              bool aa = await provider.resetPassword(
                                context,
                                payload,
                              );
                              if (aa && context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (builder) => const LoginPage(),
                                  ),
                                      (Route<dynamic> route) => false,
                                );
                              }
                            }
                          },
                          child: provider.isLoading
                              ? SizedBox(
                            height: 24.h,
                            width: 24.h,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Text(
                            "Tasdiqlash",
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.nunito(
                            color: AppColors.grey_400,
                            fontSize: 12.sp,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  "Kirish tugmasini bosish orqali siz barcha ",
                            ),
                            TextSpan(
                              text: "Foydalanish qoidalari",
                              style: TextStyle(
                                color: AppColors.grey_900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " va "),
                            TextSpan(
                              text: "Maxfiylik shartlariga",
                              style: TextStyle(
                                color: AppColors.grey_900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " rozi bo’lasiz."),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 36.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
