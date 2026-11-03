import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'dashboard/dashboard_screen.dart';
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
    if (index == 2) {
      // Edukasi / Panduan dialog
      _showEducationBottomSheet();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _openCreateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateReportScreen()),
    );
  }

  void _showEducationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.eco, color: AppColors.primary, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Pilah Sampah dengan Benar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'AI kami dilatih mengenali 3 kategori sampah utama untuk daur ulang optimal:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildCategoryEduCard(
                      title: 'Sampah Organik (Organic Waste)',
                      desc: 'Sisa makanan, kulit buah, dedaunan, sayuran. Dapat terurai alami menjadi pupuk kompos atau pakan maggot.',
                      color: AppColors.primary,
                      icon: Icons.grass,
                      tag: 'Mudah Terurai',
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryEduCard(
                      title: 'Sampah Plastik (Plastic Waste)',
                      desc: 'Botol PET, kemasan snack, kantong plastik kresek. Pisahkan dan bersihkan dari cairan agar bernilai jual tinggi.',
                      color: const Color(0xFF0F766E),
                      icon: Icons.local_drink,
                      tag: 'Daur Ulang Industri',
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryEduCard(
                      title: 'Sampah Kertas (Paper Waste)',
                      desc: 'Kardus, kertas HVS, karton makanan, koran. Jaga tetap kering agar serat selulosa kertas dapat didaur ulang.',
                      color: const Color(0xFFD97706),
                      icon: Icons.inventory_2,
                      tag: 'Daur Ulang Kertas',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryEduCard({
    required String title,
    required String desc,
    required Color color,
    required IconData icon,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardScreen(isNested: true),
      const ReportHistoryScreen(isNested: true),
      const SizedBox(), // Placeholder for Edukasi (handled by bottom sheet)
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
