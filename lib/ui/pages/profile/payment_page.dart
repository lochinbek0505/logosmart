import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../auth/widgets/input_form_widget.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> with WidgetsBindingObserver{
  TextEditingController _amountController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPaymentStarted = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isPaymentStarted) {
      _isPaymentStarted = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ProfileProvider>(context, listen: false).init(context);
      });


      print("Foydalanuvchi to'lov ilovasidan qaytib keldi!");
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProfileProvider>(context);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.arrow_back, size: 24.w),
                      ),
                      SizedBox(width: 24.w),
                      Text(
                        "Pul yechish",
                        style: GoogleFonts.nunito(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.main_blue_900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      width: size.width,
                      height: 54.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            spreadRadius: 2.r,
                            blurRadius: 2.r,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Balans : ${provider.profileResponse.amount} so'm",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: AppColors.main_blue_600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Form(
                    key: _formKey,
                    child: InputFormWidget(
                      controller: _amountController,
                      label: "Mablag’ni kiriting",
                      isPhone: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Mablag'ni kiritish shart";
                        }

                        final amount = num.tryParse(v.replaceAll(' ', ''));
                        if (amount == null || amount <= 0) {
                          return "To'g'ri miqdorni kiriting";
                        }

                        if (amount < 100) {
                          return "Summa kamida 100 so'm bo'lishi kerak";
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Column(
                children: [
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
                          disabledBackgroundColor: AppColors.main_blue_600
                              .withOpacity(0.7),
                        ),
                        // isLoading true bo'lsa, tugma bosilmaydi
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                FocusScope.of(context).unfocus();

                                if (_formKey.currentState!.validate()) {
                                  var payload = {
                                    "amount": _amountController.text.replaceAll(
                                      ' ',
                                      '',
                                    ),
                                  };
                                  setState(() {
                                    _isPaymentStarted = true;
                                  });
                                  await provider.createPayLink(
                                    context,
                                    payload,
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
                                "To'lov qilish",
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
