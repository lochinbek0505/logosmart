import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:logosmart/core/service/notification_service.dart';
import 'package:logosmart/models/notification_model.dart';
import 'package:logosmart/ui/pages/profile/providers/notifications_provider.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Ro'yxat oxiriga yaqinlashganda keyingi sahifani yuklaymiz
  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<NotificationsProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationsProvider>();
    final items = provider.items;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        "assets/images/arow_back.png",
                        width: 22,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Bildirishnoma",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                    ),
                    if (provider.unreadCount > 0)
                      GestureDetector(
                        onTap: provider.markAllRead,
                        child: Text(
                          "Hammasini o'qish",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff20B9E8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff20B9E8),
                        ),
                      )
                    : RefreshIndicator(
                        color: Color(0xff20B9E8),
                        onRefresh: provider.refresh,
                        child: items.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount:
                                    items.length +
                                    (provider.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= items.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xff20B9E8),
                                        ),
                                      ),
                                    );
                                  }
                                  return _notificationCard(items[index]);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    // RefreshIndicator ishlashi uchun scroll bo'ladigan bo'lishi kerak
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120.h),
        Icon(
          Icons.notifications_none,
          size: 64.w,
          color: Colors.blueGrey.shade200,
        ),
        SizedBox(height: 12.h),
        Text(
          "Hozircha bildirishnomalar yo'q",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp),
        ),
      ],
    );
  }

  Widget _notificationCard(NotificationItem item) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 14),
      child: GestureDetector(
        onTap: () => _onTap(item),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: item.read ? Colors.white : Color(0xffE9F8FD),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                spreadRadius: 3,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xff20B9E8),
                child: Icon(_iconFor(item.type), color: Colors.white),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? "",
                      style: TextStyle(
                        color: Color(0xff276275),
                        fontSize: 16.sp,
                        fontWeight: item.read
                            ? FontWeight.w600
                            : FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      item.body ?? "",
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xff276275),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _formatDate(item.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.read)
                Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.only(left: 8, top: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff20B9E8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(NotificationItem item) {
    if (!item.read && item.id != null) {
      context.read<NotificationsProvider>().markRead(item.id!);
    }
    // billing / subscription bo'lsa o'sha ekranni ochamiz, aks holda shu yerda qolamiz
    if (item.screen == 'billing' || item.screen == 'subscription') {
      NotificationService().openFromPush({'screen': item.screen});
    }
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'PAYMENT_SUCCESS':
      case 'PAYMENT_CANCELED':
      case 'BALANCE_CHANGED':
        return Icons.account_balance_wallet_outlined;
      case 'SUBSCRIPTION_ACTIVATED':
      case 'SUBSCRIPTION_EXPIRING':
      case 'SUBSCRIPTION_EXPIRED':
        return Icons.workspace_premium_outlined;
      case 'ADMIN_MESSAGE':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat('dd.MM.yyyy, HH:mm').format(date);
  }
}
