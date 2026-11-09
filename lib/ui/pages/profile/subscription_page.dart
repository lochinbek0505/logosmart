import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logosmart/ui/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/core/utils/money_format.dart';
import 'package:logosmart/models/plans_model.dart' as plan;
import 'package:logosmart/models/promo_check_model.dart';
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

class _SubscriptionPageState extends State<SubscriptionPage>
    with WidgetsBindingObserver {
  int? selectedIndex;

  /// Tasdiqlangan promokod (DISCOUNT_PERCENT yoki FREE_DAYS)
  PromoCheckModel? _promo;

  /// Rejalar so'rovi tugadi — shundan keyingina "yuklab bo'lmadi" ko'rsatiladi
  bool _plansRequested = false;

  /// Click ochildi — pul tushishi va obuna faollashishi kutilmoqda
  bool _awaitingPayment = false;

  /// Click'dan qaytgach server bir necha marta tekshiriladi
  bool _checking = false;
  Timer? _pollTimer;
  int _polls = 0;
  static const _maxPolls = 20;

  /// To'lovdan oldingi obuna tugash sanasi — o'zgarsa obuna faollashgan
  dynamic _expiryBefore;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingPayment) {
      _startPolling();
    }
  }

  Future<void> _confirm(ProfileProvider provider, plan.DataList p) async {
    final messenger = ScaffoldMessenger.of(context);
    _expiryBefore = provider.profileResponse.subscriptionExpiresAt;

    // Balans yetmasa server yetmagan summa uchun Click havolasini qaytaradi —
    // pul tushishi bilan obuna serverda shu rejaga faollashadi
    final result = await provider.checkoutPlan(
      context,
      p.code ?? "",
      _promo?.code ?? "",
    );
    if (!mounted) return;
    switch (result) {
      case PlanCheckoutResult.activated:
        _onActivated();
      case PlanCheckoutResult.paymentStarted:
        setState(() => _awaitingPayment = true);
      case PlanCheckoutResult.linkFailed:
        messenger.showSnackBar(
          const SnackBar(
            content: Text("To'lov sahifasini ochib bo'lmadi"),
            backgroundColor: Colors.red,
          ),
        );
      case PlanCheckoutResult.failed:
        // Xato matni ApiService da ko'rsatilgan
        break;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _polls = 0;
    _checkNow();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (_polls >= _maxPolls) {
        t.cancel();
        if (mounted) setState(() => _checking = false);
        return;
      }
      _checkNow();
    });
  }

  Future<void> _checkNow() async {
    if (!mounted || !_awaitingPayment) return;
    _polls++;
    setState(() => _checking = true);
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final activated = await provider.settlePendingPlan(context, _expiryBefore);
    if (!mounted) return;
    if (activated) {
      _onActivated();
    } else if (_pollTimer?.isActive != true) {
      setState(() => _checking = false);
    }
  }

  void _onActivated() {
    _pollTimer?.cancel();
    setState(() {
      _awaitingPayment = false;
      _checking = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sizning obunangiz muvaffaqiyatli faollashtirildi!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _closeWaiting() {
    _pollTimer?.cancel();
    setState(() {
      _awaitingPayment = false;
      _checking = false;
    });
  }

  Widget _waitingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Container(
          padding: EdgeInsets.fromLTRB(22.w, 26.h, 22.w, 18.h),
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 54.w,
                width: 54.w,
                child: _checking
                    ? const CircularProgressIndicator(
                        color: AppColors.main_blue_600,
                        strokeWidth: 4,
                      )
                    : Icon(
                        Icons.hourglass_top_rounded,
                        size: 54.w,
                        color: AppColors.main_blue_600,
                      ),
              ),
              SizedBox(height: 16.h),
              Text(
                "To'lov kutilmoqda",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: context.palette.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Click'da to'lovni yakunlang. Pul tushishi bilan obuna "
                "avtomatik faollashadi.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14.sp,
                  color: context.palette.textSecondary,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main_blue_600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  onPressed: _checking ? null : _startPolling,
                  child: Text(
                    "Tekshirish",
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: _closeWaiting,
                child: Text(
                  "Yopish",
                  style: GoogleFonts.nunito(
                    color: context.palette.textSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      body: Stack(
        children: [
          SizedBox(
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
          if (_awaitingPayment) _waitingOverlay(),
        ],
      ),
    );
  }
}
