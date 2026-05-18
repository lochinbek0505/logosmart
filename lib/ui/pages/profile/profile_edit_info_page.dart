import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/providera/auth_provider.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import '../auth/widgets/input_dropdown_widget.dart';
import '../auth/widgets/input_form_widget.dart';

class ProfileEditInfoPage extends StatefulWidget {
  const ProfileEditInfoPage({super.key});

  @override
  State<ProfileEditInfoPage> createState() => _ProfileEditInfoPageState();
}

class _ProfileEditInfoPageState extends State<ProfileEditInfoPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  Map<String, dynamic>? selectedRegionValue;
  Map<String, dynamic>? selectedDistrictValue;
  int? selectedAgeValue;

  List<int> ages = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    for (int i = 1; i <= 100; i++) {
      ages.add(i);
    }
    _load();
  }

  void _load() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final provider2 = Provider.of<AuthProvider>(context, listen: false);
    await provider2.initRegions();
    await provider.init(context);

    // Profile data bilan default qiymatlar
    final profile = provider.profileResponse;
    _nameController.text = profile.fullName ?? "";
    selectedAgeValue = profile.age?.toInt();
    if (profile.region != null) {
      selectedRegionValue = provider2.regionsList.firstWhere(
        (r) => r['name'] == profile.region,
        orElse: () => {},
      );
      if (selectedRegionValue != null) {
        provider2.getDistricts(selectedRegionValue!['id']);
        if (profile.district != null) {
          selectedDistrictValue = provider2.districts.firstWhere(
            (d) => d['name'] == profile.district,
            orElse: () => {},
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final regions = authProvider.regionsList;
    final districts = authProvider.districts;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(
              color: AppColors.main_blue_900,
              size: 24.w,
            ),
            floating: true,
            snap: true,
            elevation: 0,
            title: Text(
              "Ma’lumotlarni o’zgartirish",
              style: GoogleFonts.nunito(
                color: AppColors.main_blue_900,
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
              ),
            ),
          ),

          SliverFillRemaining(
            hasScrollBody: true,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),

                      InputFormWidget(
                        controller: _nameController,
                        label: "Ism va familiya",
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Ismni kiriting";
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
                              authProvider.getDistricts(val['id']);
                            }
                          });
                        },
                        validator: (value) =>
                            value == null ? "Iltimos, viloyatni tanlang" : null,
                      ),

                      SizedBox(height: 24.h),

                      // DISTRICT
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

                      // AGE
                      InputDropdownWidget<int>(
                        label: "Yoshingizni tanlang",
                        value: selectedAgeValue,
                        items: ages,
                        onChanged: (val) {
                          setState(() {
                            selectedAgeValue = val;
                          });
                        },
                        validator: (value) => value == null
                            ? "Iltimos, yoshingizni tanlang"
                            : null,
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
                            onPressed: provider.isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final payload = {
                                        "profileImage": provider.profileResponse.profileImage,
                                        "fullName": _nameController.text.trim(),
                                        "region": selectedRegionValue?['name'],
                                        "district":
                                            selectedDistrictValue?['name'],
                                        "age": selectedAgeValue,
                                      };
                                      await provider.updateProfile(
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
                                    "Saqlash",
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
        ],
      ),
    );
  }
}
