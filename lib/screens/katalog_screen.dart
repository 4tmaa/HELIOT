import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_colors.dart';
import '../widgets/catalog/header_wave_painter.dart';
import '../widgets/catalog/featured_component_card.dart';
import '../widgets/catalog/grid_component_card.dart';

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

  final List<String> _categories = ['Semua', 'Mikrokontroler', 'Sensor'];

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
      final responseData = await Supabase.instance.client.from('components').select().order('name');
      if (mounted) {
        setState(() {
          componentList = responseData;
          isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getFilteredList() {
    List<dynamic> filtered = componentList;

    if (_selectedIndex == 1) {
      filtered = filtered.where((item) => item['category'] == 'Mikrokontroler').toList();
    } else if (_selectedIndex == 2) {
      filtered = filtered.where((item) => item['category'].toString().contains('Sensor')).toList();
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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: HeaderWavePainter(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 20),
                    child: Column(
                      children: [
                        Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
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
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.search, color: AppColors.primaryColor),
                              contentPadding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            style: const TextStyle(color: AppColors.mainTextColor),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_categories.length, (index) {
                            final isSelected = _selectedIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutQuint,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isSelected ? Colors.white : Colors.transparent),
                                ),
                                child: Text(
                                  _categories[index],
                                  style: TextStyle(
                                    color: isSelected ? AppColors.primaryColor : Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildBookCatalog(filteredList, ValueKey<String>('${_selectedIndex}_$_searchQuery')),
                    ),
            ),
          ],
        ),
    );
  }

  Widget _buildBookCatalog(List<dynamic> listData, Key key) {
    if (listData.isEmpty) {
      return Center(key: key, child: const Text('Komponen tidak ditemukan', style: TextStyle(color: AppColors.secondaryTextColor)));
    }

    final dynamic heroProduct = listData.first;
    final List<dynamic> gridProducts = listData.length > 1 ? listData.sublist(1) : [];

    return CustomScrollView(
      key: key,
      slivers: [
        SliverToBoxAdapter(child: FeaturedComponentCard(product: heroProduct)),
        if (gridProducts.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => GridComponentCard(product: gridProducts[index]),
                childCount: gridProducts.length,
              ),
            ),
          ),
      ],
    );
  }
}