import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'katalog_screen.dart';
import 'pesanan_screen.dart';
import 'profil_screen.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigation({super.key, this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  final List<Widget> screenList = [
    const BerandaScreen(),
    const KatalogScreen(),
    const PesananScreen(),
    const ProfilScreen(),
  ];

  void changeScreen(int indexValue) {
    setState(() {
      currentIndex = indexValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: (currentIndex == 0 || currentIndex == 1) ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        body: screenList[currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        height: 65,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 'Beranda', 0),
            _buildNavItem(Icons.category_outlined, Icons.category, 'Katalog', 1),
            _buildNavItem(Icons.shopping_cart_outlined, Icons.shopping_cart, 'Pesanan', 2),
            _buildNavItem(Icons.person_outline, Icons.person, 'Profil', 3),
          ],
        ),
      ),
    ));
  }

  Widget _buildNavItem(IconData outlineIcon, IconData solidIcon, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => changeScreen(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                isSelected ? solidIcon : outlineIcon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? AppColors.primaryColor : AppColors.secondaryTextColor,
                size: 26,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}