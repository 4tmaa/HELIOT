import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import 'home/kategori_detail_screen.dart';
import 'home/notifikasi_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  List<dynamic> templateList = [];
  List<dynamic> bannerList = [];
  bool isLoadingTemplates = true;
  bool isLoadingBanners = true;
  bool hasUnreadNotifications = false;
  String userName = 'Memuat...';

  final List<Map<String, dynamic>> categoryList = [
    {'icon': Icons.home_rounded, 'name': 'Smart Home', 'color': Colors.blue},
    {'icon': Icons.eco_rounded, 'name': 'Agrikultur', 'color': Colors.green},
    {'icon': Icons.precision_manufacturing_rounded, 'name': 'Robotika', 'color': Colors.orange},
    {'icon': Icons.health_and_safety_rounded, 'name': 'Keamanan', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchBannerData();
    fetchTemplateData();
    _checkUnreadNotifications();
  }

  Future<void> fetchUserProfile() async {
    try {
      final activeUser = supabaseClient.auth.currentUser;
      if (activeUser != null) {
        final profileData = await supabaseClient.from('profiles').select('full_name').eq('id', activeUser.id).single();
        if (mounted) setState(() => userName = profileData['full_name'] ?? 'Pengguna');
      }
    } catch (e) {
      if (mounted) setState(() => userName = 'Pengguna');
    }
  }

  Future<void> _checkUnreadNotifications() async {
    try {
      final activeUser = supabaseClient.auth.currentUser;
      if (activeUser == null) return;
      
      final response = await supabaseClient
          .from('notifications')
          .select('id')
          .eq('user_id', activeUser.id)
          .eq('is_read', false)
          .limit(1);
          
      if (mounted) {
        setState(() {
          hasUnreadNotifications = response.isNotEmpty;
        });
      }
    } catch (e) {
      if (mounted) setState(() => hasUnreadNotifications = false);
    }
  }

  Future<void> fetchBannerData() async {
    try {
      final responseData = await supabaseClient.from('banners').select().eq('is_active', true).order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          bannerList = responseData;
          isLoadingBanners = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingBanners = false);
    }
  }

  Future<void> fetchTemplateData() async {
    try {
      final responseData = await supabaseClient.from('templates').select().limit(5);
      if (mounted) {
        setState(() {
          templateList = responseData;
          isLoadingTemplates = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingTemplates = false);
    }
  }

  void navigateToCategory(String categoryName) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => KategoriDetailScreen(categoryName: categoryName)));
  }

  void navigateToNotifications() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const NotifikasiScreen())
    ).then((_) => _checkUnreadNotifications());
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'Harga Menyusul';
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110.0,
            toolbarHeight: 90.0,
            floating: false,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: HomeHeaderPainter(),
                      ),
                    ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Selamat Datang,', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(userName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5))),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(hasUnreadNotifications ? Icons.notifications_active_rounded : Icons.notifications_none_rounded, color: Colors.white),
                                  onPressed: navigateToNotifications,
                                ),
                                if (hasUnreadNotifications)
                                  Positioned(
                                    top: 10,
                                    right: 12,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.orangeAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                if (isLoadingBanners)
                  Container(margin: const EdgeInsets.symmetric(horizontal: 24), height: 180, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)))
                else if (bannerList.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.9),
                      itemCount: bannerList.length,
                      itemBuilder: (context, index) {
                        final banner = bannerList[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(banner['image_url'], fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: AppColors.primaryColor)),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (banner['title'] != null) Text(banner['title'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                      if (banner['subtitle'] != null) ...[
                                        const SizedBox(height: 4),
                                        Text(banner['subtitle'], style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      ]
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Kategori Proyek', style: TextStyle(color: AppColors.mainTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(categoryList.length, (index) {
                      final category = categoryList[index];
                      return GestureDetector(
                        onTap: () => navigateToCategory(category['name']),
                        child: Column(
                          children: [
                            Container(
                              height: 65,
                              width: 65,
                              decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.primaryColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]),
                              child: Icon(category['icon'], color: AppColors.primaryColor, size: 30),
                            ),
                            const SizedBox(height: 8),
                            Text(category['name'], style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rekomendasi Templat', style: TextStyle(color: AppColors.mainTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => navigateToCategory('Templat Populer'),
                        child: const Text('Lihat Semua', style: TextStyle(color: AppColors.primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoadingTemplates)
                  const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: AppColors.primaryColor)))
                else if (templateList.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Belum ada templat.', style: TextStyle(color: AppColors.secondaryTextColor))))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: templateList.length,
                    itemBuilder: (context, index) {
                      final template = templateList[index];
                      final photoUrl = template['photo_url'];
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
                              clipBehavior: Clip.antiAlias,
                              child: photoUrl != null && photoUrl.toString().isNotEmpty
                                  ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.developer_board, color: Colors.grey))
                                  : const Icon(Icons.developer_board, color: Colors.grey, size: 40),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(template['title'] ?? 'Proyek Tanpa Nama', style: const TextStyle(color: AppColors.mainTextColor, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(template['description'] ?? '-', style: const TextStyle(color: AppColors.secondaryTextColor, fontSize: 11, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 12),
                                    Text(_formatCurrency(template['estimated_price']), style: const TextStyle(color: AppColors.primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    paint.color = const Color(0xFFD92027);
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = const Color(0xFFB01A20);
    final path1 = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.3, 0)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.7, size.width, size.height * 0.9)
      ..close();
    canvas.drawPath(path1, paint);

    paint.color = Colors.white.withOpacity(0.08);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75), size.width * 0.4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}