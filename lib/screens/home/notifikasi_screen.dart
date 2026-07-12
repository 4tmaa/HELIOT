import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_loading.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndMarkNotifications();
  }

  Future<void> _fetchAndMarkNotifications() async {
    try {
      final activeUser = supabaseClient.auth.currentUser;
      if (activeUser == null) return;

      final response = await supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', activeUser.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notifications = response;
          _isLoading = false;
        });
      }

      final unreadIds = response
          .where((n) => n['is_read'] == false)
          .map((n) => n['id'])
          .toList();

      if (unreadIds.isNotEmpty) {
        await supabaseClient
            .from('notifications')
            .update({'is_read': true})
            .inFilter('id', unreadIds);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes <= 1) return 'Baru saja';
          return '${difference.inMinutes} menit yang lalu';
        }
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays == 1) {
        return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      }
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return '';
    }
  }

  Map<String, dynamic> _getNotificationStyle(String type) {
    switch (type.toLowerCase()) {
      case 'pesanan':
        return {
          'icon': Icons.local_shipping_rounded,
          'color': Colors.blueAccent,
        };
      case 'promo':
      case 'templat':
        return {
          'icon': Icons.campaign_rounded,
          'color': Colors.orangeAccent.shade700,
        };
      case 'peringatan':
        return {'icon': Icons.error_rounded, 'color': Colors.redAccent};
      default:
        return {
          'icon': Icons.notifications_active_rounded,
          'color': AppColors.primaryColor,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: _fetchAndMarkNotifications,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              iconTheme: const IconThemeData(color: AppColors.mainTextColor),
              centerTitle: true,
              title: const Text(
                'Notifikasi',
                style: TextStyle(
                  color: AppColors.mainTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (_isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: CustomShimmerCard(height: 100, borderRadius: 16),
                  ),
                  childCount: 6,
                ),
              )
            else if (_notifications.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Notifikasi',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pemberitahuan terkait pesanan akan muncul di sini.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final notif = _notifications[index];
                    final style = _getNotificationStyle(
                      notif['type'] ?? 'info',
                    );
                    final bool isRead = notif['is_read'] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isRead
                            ? Colors.white
                            : style['color'].withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isRead
                              ? Colors.grey.shade100
                              : style['color'].withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: isRead
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: style['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              style['icon'],
                              color: style['color'],
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif['title'] ?? 'Pemberitahuan',
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                          fontSize: 15,
                                          fontWeight: isRead
                                              ? FontWeight.bold
                                              : FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: style['color'],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notif['message'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _formatTime(notif['created_at']),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: _notifications.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
