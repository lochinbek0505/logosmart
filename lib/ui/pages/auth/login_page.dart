import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/forgot_password_page.dart';
import 'package:logosmart/ui/pages/auth/otp_verification_page.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/auth/register_information_page.dart'
    show RegisterInformationPage;
import 'package:logosmart/ui/pages/auth/register_page.dart';
import 'package:logosmart/ui/pages/auth/widgets/input_form_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _phoneController;
  late TextEditingController _passwordInitController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordInitController = TextEditingController();
    _phoneController.text = "+998";
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordInitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
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
                    SizedBox(height: 63.h),
                    Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: Text(
                        "Ilovaga kirish",
                        style: GoogleFonts.nunito(
                          color: AppColors.grey_900,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: Text(
                        "Logosmart ilovasiga Xush kelibsiz!",
                        style: GoogleFonts.nunito(
                          color: AppColors.grey_700,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Form elementlari
                    InputFormWidget(
                      controller: _phoneController,
                      label: "Telefon raqamingiz",
                      isPhone: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        LengthLimitingTextInputFormatter(13),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Telefon raqam kiritilishi shart";
                        }
                        final phoneRegex = RegExp(r'^\+998[0-9]{9}$');
                        if (!phoneRegex.hasMatch(v)) return "Format noto'g'ri";
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),
                    InputFormWidget(
                      controller: _passwordInitController,
                      label: "Parol",
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Parol kiritilishi shart";
                        }
                        if (v.length < 8) {
                          return "Parol kamida 8 ta belgidan iborat bo'lishi kerak";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (builder) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Login yoki parol esdan chiqdimi?",
                            style: GoogleFonts.nunito(
                              color: AppColors.red_500,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    SizedBox(height: 24.h),

                    // KIRISH TUGMASI
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
                            // Disabled holatida tugma rangi o'zgarib qolmasligi uchun (ixtiyoriy)
                            disabledBackgroundColor: AppColors.main_blue_600
                                .withOpacity(0.7),
                          ),
                          // DIQQAT: provider.isLoading true bo'lsa, tugma bosilmaydi (null)
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();

                                  if (_formKey.currentState!.validate()) {
                                    bool isSuccess = await provider.loginInit(
                                      context,
                                      _phoneController.text,
                                      _passwordInitController.text,
                                    );

                                    if (isSuccess && context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (builder) =>
                                              OtpVerificationPage(
                                                check: "login",
                                                phone: _phoneController.text,
                                              ),
                                        ),
                                      );
                                    }
                                  }else{
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (builder) =>
                                            OtpVerificationPage(
                                              check: "login",
                                              phone: _phoneController.text,
                                            ),
                                      ),
                                    );
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
                                  "Kirish",
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            elevation: 0,
                            side: BorderSide(color: AppColors.main_blue_600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (builder) =>
                                    const RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Yangi hisob yaratish",
                            style: GoogleFonts.nunito(
                              color: AppColors.grey_900,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
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
