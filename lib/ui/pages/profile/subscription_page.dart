import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/utils/money_format.dart';
import 'package:logosmart/models/plans_model.dart' as plan;
import 'package:logosmart/models/promo_check_model.dart';
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
  int? selectedIndex;

  /// Tasdiqlangan promokod (DISCOUNT_PERCENT yoki FREE_DAYS)
  PromoCheckModel? _promo;

  /// Rejalar so'rovi tugadi — shundan keyingina "yuklab bo'lmadi" ko'rsatiladi
  bool _plansRequested = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      await provider.initPlans(context);
      if (!mounted) return;
      _plansRequested = true;
      final plans = provider.plansModel.dataListList ?? [];
      // Birinchi tanlash mumkin bo'lgan reja oldindan belgilanadi
      final first = plans.indexWhere((p) => _isSelectable(provider, p));
      setState(() => selectedIndex = first == -1 ? null : first);
    });
  }

  /// Hozir amal qilayotgan pullik reja (bo'lmasa null).
  /// DEFAULT, PROMO_FREE yoki muddati tugagan obuna — cheklov yo'q.
  plan.DataList? _activePlan(ProfileProvider provider) {
    final profile = provider.profileResponse;
    if (!profile.hasActiveSubscription) return null;
    final plans = provider.plansModel.dataListList ?? [];
    for (final p in plans) {
      if (p.code == profile.subscriptionCode) return p;
    }
    return null;
  }

  /// Faol obuna bo'lsa — shu reja yoki undan uzunrog'i (uzaytirish yoki
  /// yuqoriga o'tish). Backend yangi muddatni eski tugash sanasiga qo'shadi.
  bool _isSelectable(ProfileProvider provider, plan.DataList p) {
    final active = _activePlan(provider);
    if (active == null) return true;
    return (p.durationDays ?? 0) >= (active.durationDays ?? 0);
  }

  num _discountPercent() =>
      _promo?.type == "DISCOUNT_PERCENT" ? (_promo!.discountPercent ?? 0) : 0;

  num _finalPrice(plan.DataList p) {
    final price = p.price ?? 0;
    final discounted = price - price * _discountPercent() / 100;
    return discounted < 0 ? 0 : discounted;
  }

  Future<void> _enterPromo() async {
    final result = await showDialog<PromoCheckModel>(
      context: context,
      builder: (_) => const PromoCodeDialog(),
    );
    if (result == null || !mounted) return;
    setState(() => _promo = result);
  }

  Future<void> _confirm(ProfileProvider provider, plan.DataList p) async {
    final messenger = ScaffoldMessenger.of(context);
    final price = _finalPrice(p);
    final balance = provider.profileResponse.amount ?? 0;

    if (price > balance) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Hisobingizda yetarli mablag' yo'q (kerak: ${formatSom(price)} so'm). "
            "Iltimos, hisobni to'ldiring!",
          ),
          backgroundColor: Colors.red,
        ),
      );
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (builder) => PaymentPage()),
      );
      // To'lovdan qaytgach balans yangilanadi
      if (mounted) await provider.init(context, silent: true);
      return;
    }

    final ok = await provider.activatePlan(
      context,
      p.code ?? "",
      _promo?.code ?? "",
    );
    if (!mounted || !ok) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text("Sizning obunangiz muvaffaqiyatli faollashtirildi!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    final plans = provider.plansModel.dataListList ?? [];
    final hasData = plans.isNotEmpty;
    final activePlan = _activePlan(provider);
    final selected = selectedIndex != null && selectedIndex! < plans.length
        ? plans[selectedIndex!]
        : null;
    final promoTexts = selected?.promoTextsList ?? [];
    final freeDays = _promo?.type == "FREE_DAYS"
        ? num.tryParse("${_promo?.freeDays}") ?? 0
        : 0;

    return Scaffold(
      backgroundColor: context.palette.background,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: context.palette.background,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 24.w,
            color: context.palette.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ilovani sotib olish",
          style: GoogleFonts.nunito(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: context.palette.textPrimary,
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
                ...plans.asMap().entries.map((entry) {
                  final index = entry.key;
                  final p = entry.value;
                  final texts = p.promoTextsList ?? [];
                  final selectable = _isSelectable(provider, p);

                  return Opacity(
                    opacity: selectable ? 1 : 0.5,
                    child: CustomSubscriptionCard(
                      isSelected: selectedIndex == index,
                      title: p.name ?? "Nomsiz",
                      bonusText: texts.length > 1 ? texts[1] : "",
                      onTap: selectable
                          ? () => setState(() => selectedIndex = index)
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Obunangiz faol: faqat ${activePlan?.durationDays} kunlik yoki undan uzunroq reja tanlanadi.",
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                    ),
                  );
                }),

                if (_plansRequested && !provider.isPlansLoading && !hasData)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Text(
                      "Obuna rejalarini yuklab bo'lmadi",
                      style: GoogleFonts.nunito(
                        color: context.palette.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),

                if (!_plansRequested && !hasData)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.main_blue_600,
                    ),
                  ),

                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: provider.isActionLoading ? null : _enterPromo,
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
                          color: context.palette.surface,
                          borderRadius: BorderRadius.circular(36.r),
                          border: Border.all(
                            color: context.palette.border,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _promo == null
                              ? "Promokod bormi?"
                              : freeDays > 0
                              ? "Promokod: ${_promo!.code} (+$freeDays kun bepul)"
                              : "Promokod: ${_promo!.code} (-${_discountPercent()}%)",
                          style: GoogleFonts.nunito(
                            color: context.palette.textStrong,
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
                  features: selected?.featuresList ?? [],
                  currentPrice: selected == null
                      ? ""
                      : formatSom(_finalPrice(selected)),
                  // Chegirma bo'lsa asl narx, bo'lmasa reja promo matni
                  oldPrice: selected == null
                      ? ""
                      : _discountPercent() > 0
                      ? formatSom(selected.price)
                      : (promoTexts.isNotEmpty ? promoTexts.first : ""),
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
                          .withValues(alpha: 0.7),
                    ),
                    onPressed: provider.isActionLoading || selected == null
                        ? null
                        : () => _confirm(provider, selected),
                    child: provider.isActionLoading
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
