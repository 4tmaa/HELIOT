import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';

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

      final unreadIds = response.where((n) => n['is_read'] == false).map((n) => n['id']).toList();
      
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
        return {'icon': Icons.shopping_bag_outlined, 'color': Colors.blue};
      case 'promo':
      case 'templat':
        return {'icon': Icons.campaign_outlined, 'color': Colors.orange};
      case 'peringatan':
        return {'icon': Icons.warning_amber_rounded, 'color': Colors.red};
      default:
        return {'icon': Icons.info_outline_rounded, 'color': AppColors.primaryColor};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: _fetchAndMarkNotifications,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 90.0,
              toolbarHeight: 70.0,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              title: const Text('Notifikasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              flexibleSpace: FlexibleSpaceBar(
                background: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                  child: CustomPaint(
                    painter: NotifikasiHeaderPainter(),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
              )
            else if (_notifications.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 80, color: AppColors.secondaryTextColor.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('Belum Ada Notifikasi', style: TextStyle(color: AppColors.mainTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Pemberitahuan terkait pesanan akan muncul di sini.', style: TextStyle(color: AppColors.secondaryTextColor)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notif = _notifications[index];
                      final style = _getNotificationStyle(notif['type'] ?? 'info');
                      final bool isRead = notif['is_read'] ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isRead ? AppColors.surfaceColor : style['color'].withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isRead ? Colors.transparent : style['color'].withOpacity(0.3)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: style['color'].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(style['icon'], color: style['color'], size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif['title'] ?? 'Pemberitahuan',
                                          style: TextStyle(color: AppColors.mainTextColor, fontSize: 15, fontWeight: isRead ? FontWeight.bold : FontWeight.w900),
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(color: style['color'], shape: BoxShape.circle),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    notif['message'] ?? '',
                                    style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 13, height: 1.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _formatTime(notif['created_at']),
                                    style: TextStyle(color: AppColors.secondaryTextColor.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _notifications.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotifikasiHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    paint.color = const Color(0xFFD92027);
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = const Color(0xFFB01A20);
    final path1 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.3, size.height * 1.0, size.width * 0.7, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.4, size.width, size.height * 0.5)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path1, paint);

    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.3), size.width * 0.25, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}