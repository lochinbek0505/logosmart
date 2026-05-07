import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logosmart/ui/pages/auth/widgets/input_form_widget.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:logosmart/ui/pages/profile/providers/profile_provider.dart';
import 'package:logosmart/models/promo_check_model.dart';

class PromoCodeDialog extends StatefulWidget {
  const PromoCodeDialog({super.key});

  @override
  State<PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<PromoCodeDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool? _isValid;

  Future<void> _checkPromo(BuildContext context) async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() {
        _message = "Promo kodni kiriting";
        _isValid = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
      _isValid = null;
    });

    final provider = context.read<ProfileProvider>();
    final PromoCheckModel result = await provider.checkPromoCode(context, code);

    final valid = result.valid == true &&
        result.expired != true &&
        result.limitReached != true;

    setState(() {
      _isLoading = false;
      _isValid = valid;
      _message = result.message ??
          (valid ? "Promo kod muvaffaqiyatli!" : "Promo kod yaroqsiz");
    });

    if (valid && mounted) {
      Navigator.pop(context, code); // promo kodni qaytaradi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [


            InputFormWidget(controller: _controller, label: "Promo kodni kiriting"),
            SizedBox(height: 10.h),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _isValid == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
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
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  disabledBackgroundColor: AppColors.main_blue_600
                      .withOpacity(0.7),
                ),
                onPressed: _isLoading ? null : () => _checkPromo(context),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    :  Text("Tasdiqlash",style: GoogleFonts.nunito(color: Colors.white,fontSize: 15.sp),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}