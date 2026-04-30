import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/otp_verification_page.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/auth/widgets/input_form_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late TextEditingController _phoneController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneController.text = "+998";
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black, size: 24.w),
        backgroundColor: AppColors.white,
        title: Text(
          "Qayta tiklash",
          style: GoogleFonts.nunito(
            color: AppColors.grey_900,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    "Logosmart ilovasidagi login yoki parolingizni faqat nomeringiz orqali qayta tiklashingiz mumkin!",
                    style: GoogleFonts.nunito(
                      color: AppColors.grey_700,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
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
                        disabledBackgroundColor: AppColors.main_blue_600
                            .withOpacity(0.7),
                      ),
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                var payload = {
                                  "phoneNumber": _phoneController.text,
                                };
                                bool aa = await provider.forgotInit(
                                  context,
                                  payload,
                                );
                                if (aa && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (builder) => OtpVerificationPage(
                                        check: "forgot_password",
                                        phone: _phoneController.text,
                                      ),
                                    ),
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
                          text: "Kirish tugmasini bosish orqali siz barcha ",
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
    );
  }
}
