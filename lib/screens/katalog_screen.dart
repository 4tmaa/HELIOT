import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_colors.dart';
import '../widgets/catalog/featured_component_card.dart';
import '../widgets/catalog/grid_component_card.dart';
import '../widgets/custom_loading.dart';
import '../widgets/custom_toast.dart';
import '../services/local_db_service.dart';

class KatalogScreen extends StatefulWidget {
  const KatalogScreen({super.key});

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> componentList = [];
  bool isLoading = true;
  int _selectedIndex = 0;
  String _searchQuery = '';
  final List<String> _categories = ['Semua', 'Mikrokontroler', 'Sensor', 'Aktuator', 'Komunikasi', 'Display', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    fetchComponentData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchComponentData() async {
    try {
      final cached = await LocalDatabaseService.instance.getCachedData('components', maxAge: null);

      if (cached != null) {
        if (mounted) {
          setState(() {
            componentList = List<dynamic>.from(cached).where((e) => e['is_deleted'] != true).toList();
            isLoading = false;
          });
        }
        
        final lastSync = LocalDatabaseService.instance.getMaxUpdatedAt(List<dynamic>.from(cached));
        final delta = await Supabase.instance.client
            .from('components')
            .select()
            .gt('updated_at', lastSync);
        
        if (delta.isNotEmpty) {
          final merged = LocalDatabaseService.instance.mergeData(List<dynamic>.from(cached), delta);
          await LocalDatabaseService.instance.saveToCache('components', merged);
          if (mounted) {
            setState(() {
              final activeComponents = merged.where((e) => e['is_deleted'] != true).toList();
              // Sort by name
              activeComponents.sort((a, b) => (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
              componentList = activeComponents;
            });
          }
        }
      } else {
        final responseData = await Supabase.instance.client
            .from('components')
            .select()
            .order('name');
            
        await LocalDatabaseService.instance.saveToCache('components', responseData);
        if (mounted) {
          setState(() {
            componentList = responseData.where((e) => e['is_deleted'] != true).toList();
            isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        CustomToast.show(
          context,
          message: 'Gagal memuat katalog',
          type: ToastType.error,
        );
      }
    }
  }

  List<dynamic> _getFilteredList() {
    List<dynamic> filtered = componentList;

    if (_selectedIndex > 0 && _selectedIndex < _categories.length) {
      final selectedCategory = _categories[_selectedIndex];
      filtered = filtered
          .where((item) => item['category'].toString().contains(selectedCategory))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = item['name'].toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Text(
                    'Katalog',
                    style: TextStyle(
                      color: AppColors.mainTextColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primaryColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari komponen...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primaryColor,
                            ),
                            suffixIcon: PopupMenuButton<int>(
                              icon: const Icon(
                                Icons.tune,
                                color: AppColors.primaryColor,
                              ),
                              onSelected: (int index) {
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return List.generate(_categories.length, (
                                  index,
                                ) {
                                  return PopupMenuItem<int>(
                                    value: index,
                                    child: Text(
                                      _categories[index],
                                      style: TextStyle(
                                        color: _selectedIndex == index
                                            ? AppColors.primaryColor
                                            : AppColors.mainTextColor,
                                        fontWeight: _selectedIndex == index
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                });
                              },
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                            ),
                          ),
                          style: const TextStyle(
                            color: AppColors.mainTextColor,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 8),
          Expanded(
            child: isLoading
                ? _buildShimmerLoading()
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildBookCatalog(
                      filteredList,
                      ValueKey<String>('${_selectedIndex}_$_searchQuery'),
                    ),
                  ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  Widget _buildBookCatalog(List<dynamic> listData, Key key) {
    if (listData.isEmpty) {
      return Center(
        key: key,
        child: const Text(
          'Komponen tidak ditemukan',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
      );
    }

    final dynamic heroProduct = listData.first;
    final List<dynamic> gridProducts = listData.length > 1
        ? listData.sublist(1)
        : [];

    return CustomScrollView(
      key: key,
      slivers: [
        SliverToBoxAdapter(child: FeaturedComponentCard(product: heroProduct)),
        if (gridProducts.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    GridComponentCard(product: gridProducts[index]),
                childCount: gridProducts.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: CustomShimmerCard(height: 220, borderRadius: 24),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const CustomShimmerCard(borderRadius: 20),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}
