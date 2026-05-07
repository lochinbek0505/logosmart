import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/pages/profile/widgets/custom_subscription_card.dart';
import 'package:logosmart/ui/pages/profile/widgets/pricing_card_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedIndex = 0;
  List<String> features = [];
  String currentPrice = "";
  String oldPrice = "";
  String code = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.initPlans(context);

      if (!mounted) return;

      final hasData =
          provider.plansModel.dataListList != null &&
          provider.plansModel.dataListList!.isNotEmpty;

      if (hasData) {
        final firstPlan = provider.plansModel.dataListList!.first;

        setState(() {
          features = firstPlan.featuresList ?? [];
          currentPrice = (firstPlan.price ?? "").toString();
          oldPrice =
              (firstPlan.promoTextsList != null &&
                  firstPlan.promoTextsList!.isNotEmpty)
              ? (firstPlan.promoTextsList!.first ?? "")
              : "";
          code = firstPlan.code ?? "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    final hasData =
        provider.plansModel.dataListList != null &&
        provider.plansModel.dataListList!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 24.w,
            color: AppColors.main_blue_900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ilovani sotib olish",
          style: GoogleFonts.nunito(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.main_blue_900,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 9.h),
                if (hasData)
                  ...provider.plansModel.dataListList!.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final plan = entry.value;
                    final promoTexts = plan.promoTextsList ?? [];

                    return CustomSubscriptionCard(
                      isSelected: selectedIndex == index,
                      title: plan.name ?? "Nomsiz",
                      bonusText: promoTexts.length > 1
                          ? (promoTexts[1] ?? "")
                          : "",
                      onTap: () {
                        setState(() {
                          features = plan.featuresList ?? [];
                          currentPrice = (plan.price ?? "").toString();
                          oldPrice = promoTexts.isNotEmpty
                              ? (promoTexts.first ?? "")
                              : "";
                          selectedIndex = index;
                          code = plan.code ?? "";
                        });
                      },
                    );
                  }),

                if (provider.isLoading && !hasData)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.main_blue_600,
                    ),
                  ),

                SizedBox(height: 16.h),
                PricingCardWidget(
                  features: features,
                  currentPrice: currentPrice,
                  oldPrice: oldPrice,
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
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
                          var a=  await provider.activatePlan(context, code, "");
                          if(a){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Sizning obunangiz muvaffaqiyatli faollashtirildi!"),
                                backgroundColor: Colors.green,
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
                            "Tasdiqlash",
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
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
