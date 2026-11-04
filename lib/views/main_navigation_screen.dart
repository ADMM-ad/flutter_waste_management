import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
import 'education/education_screen.dart';
import 'report/create_report_screen.dart';
import 'report/report_history_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _openCreateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardScreen(isNested: true),
      const ReportHistoryScreen(isNested: true),
      const EducationScreen(isNested: true),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      // Center Floating Action Button Highlight (DESIGN.md Official)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 10),
        child: FloatingActionButton(
          onPressed: _openCreateReport,
          elevation: 6,
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          tooltip: 'Tambah Laporan Sampah',
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
              SizedBox(height: 2),
              Text(
                'Lapor',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar with Notched Center
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 12,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Group: Beranda & Riwayat
            Row(
              children: [
                _buildNavItem(index: 0, icon: Icons.home_rounded, label: 'Beranda'),
                const SizedBox(width: 8),
                _buildNavItem(index: 1, icon: Icons.receipt_long_rounded, label: 'Riwayat'),
              ],
            ),

            // Middle Space reserved for Docked FAB
            const SizedBox(width: 48),

            // Right Group: Edukasi & Profil
            Row(
              children: [
                _buildNavItem(index: 2, icon: Icons.eco_rounded, label: 'Edukasi'),
                const SizedBox(width: 8),
                _buildNavItem(index: 3, icon: Icons.person_rounded, label: 'Profil'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
