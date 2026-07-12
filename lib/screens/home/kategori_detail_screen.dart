import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_loading.dart';
import '../../services/local_db_service.dart';

class KategoriDetailScreen extends StatefulWidget {
  final String categoryName;

  const KategoriDetailScreen({super.key, required this.categoryName});

  @override
  State<KategoriDetailScreen> createState() => _KategoriDetailScreenState();
}

class _KategoriDetailScreenState extends State<KategoriDetailScreen> {
  List<dynamic> categoryItems = [];
  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    fetchItemsByCategory();
  }

  Future<void> fetchItemsByCategory() async {
    try {
      final cacheKey = 'kategori_${widget.categoryName}';
      final cached = await LocalDatabaseService.instance.getCachedData(
        cacheKey, maxAge: null,
      );

      if (cached != null) {
        if (mounted) {
          setState(() {
            categoryItems = List<dynamic>.from(cached).where((e) => e['is_deleted'] != true).toList();
            isLoadingData = false;
          });
        }
        
        final lastSync = LocalDatabaseService.instance.getMaxUpdatedAt(List<dynamic>.from(cached));
        final supabase = Supabase.instance.client;
        List<dynamic> delta = [];
        
        if (widget.categoryName == 'Templat Populer') {
          delta = await supabase.from('templates').select().gt('updated_at', lastSync);
        } else {
          delta = await supabase
              .from('templates')
              .select()
              .eq('category', widget.categoryName)
              .gt('updated_at', lastSync);
        }
        
        if (delta.isNotEmpty) {
          final merged = LocalDatabaseService.instance.mergeData(List<dynamic>.from(cached), delta);
          await LocalDatabaseService.instance.saveToCache(cacheKey, merged);
          if (mounted) {
            setState(() {
              categoryItems = merged.where((e) => e['is_deleted'] != true).toList();
            });
          }
        }
      } else {
        final supabase = Supabase.instance.client;
        List<dynamic> responseData;

        if (widget.categoryName == 'Templat Populer') {
          responseData = await supabase.from('templates').select();
        } else {
          responseData = await supabase
              .from('templates')
              .select()
              .eq('category', widget.categoryName);
        }

        await LocalDatabaseService.instance.saveToCache(cacheKey, responseData);

        if (mounted) {
          setState(() {
            categoryItems = responseData.where((e) => e['is_deleted'] != true).toList();
            isLoadingData = false;
          });
        }
      }
    } catch (error) {
      if(mounted) {
        setState(() {
          isLoadingData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
        ),
        leading: Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: AppColors.primaryColor,
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          widget.categoryName.toUpperCase(),
          style: const TextStyle(
            color: AppColors.mainTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: isLoadingData
          ? GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const CustomShimmerCard(),
            )
          : categoryItems.isEmpty
          ? Center(
              child: Text(
                'Belum ada data untuk kategori ${widget.categoryName}',
                style: const TextStyle(color: AppColors.secondaryTextColor),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: categoryItems.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 70,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.developer_board,
                          color: AppColors.primaryColor,
                          size: 35,
                        ),
                      ),
                      Text(
                        categoryItems[index]['title'] ?? '',
                        style: const TextStyle(
                          color: AppColors.mainTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Rp ${categoryItems[index]['estimated_price']}',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
