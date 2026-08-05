import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/auth/register_information_page.dart'
    show RegisterInformationPage;
import 'package:logosmart/ui/pages/auth/widgets/input_form_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
        scrolledUnderElevation: 0, // Scroll bo'lganda elevation qo'shilmasligi uchun
        surfaceTintColor: Colors.transparent, // Material 3 tint rangini olib tashlash uchun
        automaticallyImplyLeading: false, // Mana shu qator iconni yo'qotadi
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
                    SizedBox(height: 40.h),
                    Padding(
                      padding: EdgeInsets.only(left: 15.w),
                      child: Text(
                        "Yangi hisob yaratish",
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
                        if (v == null || v.isEmpty)
                          return "Tefon raqam kiritilishi shart";
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
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              var payload = {
                                "phoneNumber": _phoneController.text,
                                "password": _passwordInitController.text,
                              };
                              provider.payload = payload;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (builder) =>
                                      RegisterInformationPage(),
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Davom etish",
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
