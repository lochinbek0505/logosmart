import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/profile/payment_page.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/ui/pages/profile/widgets/custom_subscription_card.dart';
import 'package:logosmart/ui/pages/profile/widgets/pricing_card_widget.dart';
import 'package:logosmart/ui/pages/profile/widgets/promo_code_dialog.dart';
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
  bool canSubscribe = true;

  String? promoCode;
  num? promoDiscountPercent;
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
        final plans = provider.plansModel.dataListList!;
        final currentSubCode = provider.profileResponse.subscriptionCode;

        num? currentDuration;
        if (currentSubCode != null) {
          final currentPlan = plans.firstWhere(
                (p) => p.code == currentSubCode,
            orElse: () => plans.first,
          );
          currentDuration = currentPlan.durationDays;
        }

        // Tanlash mumkin bo‘lgan reja (durationDays katta)
        final eligibleIndex = plans.indexWhere((p) {
          if (currentDuration == null) return true;
          return (p.durationDays ?? 0) > currentDuration!;
        });

        if (eligibleIndex != -1) {
          final firstPlan = plans[eligibleIndex];

          setState(() {
            selectedIndex = eligibleIndex;
            features = firstPlan.featuresList ?? [];
            currentPrice = (firstPlan.price ?? "").toString();
            oldPrice =
            (firstPlan.promoTextsList != null &&
                firstPlan.promoTextsList!.isNotEmpty)
                ? (firstPlan.promoTextsList!.first ?? "")
                : "";
            code = firstPlan.code ?? "";
            canSubscribe = true;
          });
        } else {
          // Eng katta reja olingan bo‘lsa
          setState(() {
            canSubscribe = false;
          });
        }
      }
    });
  }

  String discountedPrice() {
    final price = num.tryParse(currentPrice) ?? 0;
    final discount = promoDiscountPercent ?? 0;
    final discounted = price - (price * discount / 100);
    return discounted.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    final hasData =
        provider.plansModel.dataListList != null &&
        provider.plansModel.dataListList!.isNotEmpty;

    // Hozirgi aktiv obunaning durationDays ni topamiz
    num? currentPlanDurationDays;
    final currentSubCode = provider.profileResponse.subscriptionCode;
    if (currentSubCode != null && hasData) {
      final currentPlan = provider.plansModel.dataListList!.firstWhere(
        (p) => p.code == currentSubCode,
        orElse: () => provider.plansModel.dataListList!.first,
      );
      currentPlanDurationDays = currentPlan.durationDays;
    }

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

                    final isSelectable = currentPlanDurationDays == null
                        ? true
                        : (plan.durationDays ?? 0) > currentPlanDurationDays!;

                    return CustomSubscriptionCard(
                      isSelected: selectedIndex == index,
                      title: plan.name ?? "Nomsiz",
                      bonusText: promoTexts.length > 1
                          ? (promoTexts[1] ?? "")
                          : "",
                      onTap: isSelectable
                          ? () {
                              setState(() {
                                features = plan.featuresList ?? [];
                                currentPrice = (plan.price ?? "").toString();
                                oldPrice = promoTexts.isNotEmpty
                                    ? (promoTexts.first ?? "")
                                    : "";
                                selectedIndex = index;
                                code = plan.code ?? "";
                              });
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Faqat hozirgi obunadan uzoqroq (durationDays katta) reja tanlanadi.",
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                    );
                  }),

                if (provider.isLoading && !hasData)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.main_blue_600,
                    ),
                  ),

                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: provider.isLoading
                      ? null
                      : () async {
                          final promo = await showDialog<String>(
                            context: context,
                            builder: (_) => const PromoCodeDialog(),
                          );

                          if (promo != null) {
                            final promoResult = await provider.checkPromoCode(
                              context,
                              promo,
                            );

                            if (promoResult.valid == true &&
                                promoResult.expired != true &&
                                promoResult.limitReached != true &&
                                promoResult.type == "DISCOUNT_PERCENT") {
                              setState(() {
                                promoCode = promo;
                                promoDiscountPercent =
                                    promoResult.discountPercent ?? 0;
                              });
                            } else {
                              setState(() {
                                promoCode = null;
                                promoDiscountPercent = null;
                              });
                            }
                          }
                        },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                          horizontal: 20.w,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36.r),
                          border: Border.all(
                            color: AppColors.light_grey_500,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          promoCode == null
                              ? "Promokod bormi?"
                              : "Promokod: $promoCode",
                          style: GoogleFonts.nunito(
                            color: AppColors.grey_900,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),
                PricingCardWidget(
                  features: features,
                  currentPrice: promoDiscountPercent == null
                      ? currentPrice
                      : discountedPrice(),
                  oldPrice: promoDiscountPercent == null
                      ? oldPrice
                      : currentPrice,
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
                    onPressed:provider.isLoading || !canSubscribe
                        ? null
                        : () async {
                            num? price = promoDiscountPercent == null
                                ? num.tryParse(currentPrice)
                                : num.tryParse(discountedPrice());
                            if (price! <= provider.profileResponse.amount!) {
                              var a = await provider.activatePlan(
                                context,
                                code,
                                promoCode ?? "",
                              );
                              if (a) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Sizning obunangiz muvaffaqiyatli faollashtirildi!",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Sizning hisobingizda yetarli mablag' mavjud emas , iltimos hisobni to'ldiring!",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (builder) => PaymentPage(),
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
