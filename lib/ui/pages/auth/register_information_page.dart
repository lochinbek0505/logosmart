import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/otp_verification_page.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/auth/widgets/input_form_widget.dart';
import 'package:logosmart/ui/theme/AppColors.dart';
import 'package:provider/provider.dart';

import 'widgets/input_dropdown_widget.dart';

class RegisterInformationPage extends StatefulWidget {
  const RegisterInformationPage({super.key});

  @override
  State<RegisterInformationPage> createState() =>
      _RegisterInformationPageState();
}

class _RegisterInformationPageState extends State<RegisterInformationPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  Map<String, dynamic>? selectedRegionValue;
  Map<String, dynamic>? selectedDistrictValue;
  int? selectedAgeValue;
  List<int> ages = [];

  String? selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    for (int i = 1; i <= 100; i++) {
      ages.add(i);
    }
    load();
  }

  void load() async {
    var provider = Provider.of<AuthProvider>(context, listen: false);
    await provider.initRegions();
  }

  // ============== CUSTOM DIALOG FUNKSIYASI ==============
  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Atrofga bosganda yopilmasligi uchun
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/error.png',
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error,
                          color: const Color(0xFFD93B3B),
                          size: 80.w,
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Sarlavha
                    Text(
                      "Ro'yxatdan o'tish uchun muhim:",
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF144A68),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),

                    // Xatoliklar ro'yxati
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "• ",
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF144A68),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Farzandingiz jinsini tanlashingiz shart",
                            style: GoogleFonts.nunito(
                              color: const Color(0xFF144A68),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Yopish tugmasi (X)
              Positioned(
                top: 12.h,
                right: 12.w,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFF5AC8FA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =======================================================

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AuthProvider>(context);
    var regions = provider.regionsList;
    var districts = provider.districts;

    return Scaffold(
      backgroundColor: Colors.white,
      // SingleChildScrollView va AppBar o'rniga CustomScrollView ishlatamiz
      body: CustomScrollView(
        slivers: [
          // ======== SLIVER APP BAR ========
          SliverAppBar(
            scrolledUnderElevation: 0.0,
            // Skroll bo'lganda rangi o'zgarmasligi uchun
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black, size: 24.w),
            floating: true,
            // Yoki doim tepada qotib turishini xohlasangiz `pinned: true` qiling
            snap: true,
            // Tepaga ozgina tortganda to'liq chiqib kelishi uchun
            elevation: 0,
          ),

          // ======== ASOSIY KONTENT ========
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h), // AppBar'dan keyin ozgina masofa
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      "Siz bilan yaqindan tanishamiz!",
                      style: GoogleFonts.nunito(
                        color: AppColors.grey_900,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 36.h),

                  InputFormWidget(
                    controller: _nameController,
                    label: "Farzandingizni ismini",
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Farzandingizni ismini kiriting";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),

                  InputDropdownWidget<Map<String, dynamic>>(
                    label: "Viloyatni tanlang",
                    value: selectedRegionValue,
                    items: regions,
                    onChanged: (val) {
                      setState(() {
                        selectedRegionValue = val;
                        selectedDistrictValue = null;
                        if (val != null) {
                          provider.getDistricts(val['id']);
                        }
                      });
                    },
                    validator: (value) =>
                        value == null ? "Iltimos, viloyatni tanlang" : null,
                  ),
                  SizedBox(height: 24.h),

                  Opacity(
                    opacity: selectedRegionValue == null ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: selectedRegionValue == null,
                      child: InputDropdownWidget<Map<String, dynamic>>(
                        label: "Tumanni tanlang",
                        value: selectedDistrictValue,
                        items: districts,
                        onChanged: (val) {
                          setState(() {
                            selectedDistrictValue = val;
                          });
                        },
                        validator: (value) {
                          if (selectedRegionValue == null) {
                            return "Avval viloyatni tanlang";
                          } else if (value == null) {
                            return "Iltimos, tumanni tanlang";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      "Farzandingizni jinsini tanlang",
                      style: GoogleFonts.nunito(
                        color: AppColors.grey_700,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGenderItem(
                        id: 'MALE',
                        imageAsset: 'assets/images/male.png',
                        isSelected: selectedGender == 'MALE',
                        onTap: () {
                          setState(() {
                            selectedGender = 'MALE';
                          });
                        },
                      ),
                      SizedBox(width: 36.w),
                      _buildGenderItem(
                        id: 'FEMALE',
                        imageAsset: 'assets/images/female.png',
                        isSelected: selectedGender == 'FEMALE',
                        onTap: () {
                          setState(() {
                            selectedGender = 'FEMALE';
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  InputDropdownWidget<int>(
                    label: "Farzandingizni yoshini",
                    value: selectedAgeValue,
                    items: ages,
                    onChanged: (val) {
                      setState(() {
                        selectedAgeValue = val;
                      });
                    },
                    validator: (value) => value == null
                        ? "Iltimos, farzandingizni yoshini tanlang"
                        : null,
                  ),

                  SizedBox(height: 50.h),

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
                          // Loading vaqtida tugma rangi biroz xiralashib, chiroyli turadi
                          disabledBackgroundColor: AppColors.main_blue_600
                              .withOpacity(0.7),
                        ),
                        // Agar yuklanayotgan bo'lsa (true), tugmani bosib bo'lmaydi (null)
                        onPressed: provider.isLoading
                            ? null
                            : () async {
                                if (selectedGender == null) {
                                  _showWarningDialog(context);
                                  return;
                                }

                                if (_formKey.currentState!.validate()) {
                                  var payload = {
                                    ...provider.payload,
                                    "fullName": _nameController.text,
                                    "region": selectedRegionValue?['name'],
                                    "district": selectedDistrictValue?['name'],
                                    "gender": selectedGender,
                                    "age": selectedAgeValue,
                                    "roles": ["ROLE_USER"],
                                  };
                                  provider.payload = payload;

                                  var aa = await provider.registerInit(context);

                                  if (aa && context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (builder) =>
                                            OtpVerificationPage(
                                              check: "register",
                                              phone: payload["phoneNumber"],
                                            ),
                                      ),
                                    );
                                  }
                                }
                              },
                        // Loading bo'lsa indikator aylanadi, yo'qsa yozuv chiqadi
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
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderItem({
    required String id,
    required String imageAsset,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00C2E8)
                    : AppColors.light_grey_500.withOpacity(0.5),
                width: isSelected ? 2.5 : 1.0,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    id == 'MALE' ? Icons.face : Icons.face_3,
                    color: AppColors.light_grey_500,
                    size: 60.sp,
                  );
                },
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              bottom: 4.h,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF5AC8FA),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 16.sp),
              ),
            ),
        ],
      ),
    );
  }
}
