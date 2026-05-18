import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logosmart/models/billings_model.dart';
import 'package:logosmart/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';

import 'providers/billings_provider.dart';

class BillingsPage extends StatefulWidget {
  const BillingsPage({super.key});

  @override
  State<BillingsPage> createState() => _BillingsPageState();
}

class _BillingsPageState extends State<BillingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BillingsProvider>(context, listen: false).init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BillingsProvider>(context);
    var list = provider.billingsModel.dataListList ?? [];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.main_blue_900, size: 24.w),
        title: Text(
          "To'lov tarixi",
          style: GoogleFonts.nunito(
            color: AppColors.main_blue_900,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Text(
                              "To'lovlar mavjud emas",
                              style: GoogleFonts.nunito(
                                color: AppColors.main_blue_900,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.only(bottom: 20.h),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final item = list[index];
                              final statusInfo = _statusInfo(item);

                              return _billingCard(item, statusInfo);
                            },
                          ),
                  ),
                ],
              ),
            ),
            if (provider.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.main_blue_600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _billingCard(DataList item, _StatusInfo statusInfo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 2.r,
            blurRadius: 2.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Ikonka qismi
          CircleAvatar(
            radius: 18.r,
            backgroundColor: statusInfo.bgColor,
            child: Icon(
              statusInfo.icon,
              color: statusInfo.iconColor,
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),

          // 2. Asosiy ma'lumotlar ustuni (Column)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1-qator: Title va Amount (Summa)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        statusInfo.title,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: AppColors.main_blue_900,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "${item.amount ?? "0"} so'm",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: statusInfo.amountColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // 2-qator: Description (Tavsif)
                Text(
                  item.description ?? "",
                  style: GoogleFonts.nunito(
                    fontSize: 12.sp,
                    color: AppColors.light_blue_800,
                  ),
                ),
                SizedBox(height: 6.h),

                // 3-qator: Telefon raqam va Sana
                Row(
                  children: [
                    Text(
                      item.phone ?? "",
                      style: GoogleFonts.nunito(
                        fontSize: 11.sp,
                        color: AppColors.main_blue_600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      formatDateTime(item.createdAt!) ?? "",
                      style: GoogleFonts.nunito(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // 4-qator: Xatolik matni (agar mavjud bo'lsa)
                if (item.errorNote != null)
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      "${item.errorNote}",
                      style: GoogleFonts.nunito(
                        fontSize: 11.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusInfo _statusInfo(DataList item) {
    final status = item.status ?? 0;
    if (status == 2) {
      return _StatusInfo(
        title: "Pul yechish",
        icon: Icons.arrow_upward,
        iconColor: AppColors.red_400,
        bgColor: AppColors.red_200,
        amountColor: AppColors.red_400,
      );
    }
    if (status == 1) {
      return _StatusInfo(
        title: "Pul kiritish",
        icon: Icons.arrow_downward,
        iconColor: Colors.green,
        bgColor: Colors.green.shade100,
        amountColor: Colors.green,
      );
    }
    return _StatusInfo(
      title: "Xatolik",
      icon: Icons.error_outline,
      iconColor: Colors.orange,
      bgColor: Colors.orange.shade100,
      amountColor: Colors.orange,
    );
  }

  String formatDateTime(String rawDate) {
    try {
      DateTime dt = DateTime.parse(rawDate).toLocal();
      // Format: kun.oy.yil soat:daqiqa
      return DateFormat('dd.MM.yyyy | HH:mm').format(dt);
    } catch (e) {
      return "Xato vaqt";
    }
  }
}

class _StatusInfo {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color amountColor;

  _StatusInfo({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.amountColor,
  });
}
