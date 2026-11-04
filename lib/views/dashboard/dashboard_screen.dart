import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card_widget.dart';
import '../../widgets/skeletons/dashboard_stats_skeleton.dart';
import '../../widgets/skeletons/report_card_skeleton.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import '../report/create_report_screen.dart';
import '../report/report_detail_screen.dart';
import '../report/report_history_screen.dart';
import '../../widgets/clean_flat_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  final bool isNested;
  const DashboardScreen({super.key, this.isNested = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedDateFilter = 'month'; // 'month', 'today', 'week', 'all'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      reportProvider.fetchCategories();
      _applyDateFilter('month');
    });
  }

  void _applyDateFilter(String filterKey) {
    setState(() => _selectedDateFilter = filterKey);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');

    String? start;
    String? end;

    if (filterKey == 'month') {
      start = fmt.format(DateTime(now.year, now.month, 1));
      end = fmt.format(now);
    } else if (filterKey == 'today') {
      start = fmt.format(now);
      end = fmt.format(now);
    } else if (filterKey == 'week') {
      start = fmt.format(now.subtract(const Duration(days: 7)));
      end = fmt.format(now);
    } else {
      // all
      start = null;
      end = null;
    }

    reportProvider.fetchReports(
      startDate: start,
      endDate: end,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reportProvider = Provider.of<ReportProvider>(context);
    final user = authProvider.user;

    final pendingCount = reportProvider.reports.where((r) => r.status.toLowerCase() == 'pending').length;
    final processCount = reportProvider.reports.where((r) => r.status.toLowerCase() == 'in_progress').length;
    final completedCount = reportProvider.reports.where((r) => r.status.toLowerCase() == 'completed').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CleanFlatAppBar(
        userName: user?.name ?? 'Warga',
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
        onLogoutTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Konfirmasi Keluar'),
              content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Keluar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );

          if (confirm == true && mounted) {
            await authProvider.logout();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              this.context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await reportProvider.fetchCategories();
          _applyDateFilter(_selectedDateFilter);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner call to action
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F3820),
                      Color(0xFF15803D),
                      Color(0xFF166534),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco, size: 13, color: Color(0xFF86EFAC)),
                              SizedBox(width: 4),
                              Text(
                                'Aksi Lingkungan Bersih',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Temukan Timbunan Sampah?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Foto bukti, deteksi jenis sampah dengan AI, dan kirimkan titik lokasi untuk penanganan cepat petugas.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateReportScreen()),
                        ).then((_) {
                          _applyDateFilter(_selectedDateFilter);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_a_photo, size: 18),
                      label: const Text('Buat Laporan Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Date Range Filter Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 15, color: AppColors.textPrimary),
                      SizedBox(width: 6),
                      Text(
                        'Filter Periode Data',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Text(
                    _selectedDateFilter == 'month' ? 'Bulan Ini' : (_selectedDateFilter == 'today' ? 'Hari Ini' : (_selectedDateFilter == 'week' ? '7 Hari' : 'Semua')),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Bulan Ini (Default)', 'month'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Hari Ini', 'today'),
                    const SizedBox(width: 8),
                    _buildFilterChip('7 Hari Terakhir', 'week'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Semua Waktu', 'all'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Summary Stats Row (Skeleton Loading if fetching)
              if (reportProvider.isLoadingReports)
                const DashboardStatsSkeleton()
              else
                Row(
                  children: [
                    _buildStatCard('Menunggu', pendingCount.toString(), Icons.hourglass_top_rounded, AppColors.pendingBg, AppColors.pending),
                    const SizedBox(width: 10),
                    _buildStatCard('Diproses', processCount.toString(), Icons.sync_rounded, AppColors.inProgressBg, AppColors.inProgress),
                    const SizedBox(width: 10),
                    _buildStatCard('Selesai', completedCount.toString(), Icons.check_circle_rounded, AppColors.completedBg, AppColors.completed),
                  ],
                ),

              const SizedBox(height: 24),

              // Recent Reports Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      const Text(
                        'Laporan Terkini',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${reportProvider.reports.length}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReportHistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 14),
                    label: const Text('Lihat Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Reports List Preview
              if (reportProvider.isLoadingReports)
                Column(
                  children: List.generate(3, (_) => const ReportCardSkeleton()),
                )
              else if (reportProvider.reports.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        'Belum ada laporan pada periode ini.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tekan tombol Buat Laporan untuk mengirim laporan pertama.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reportProvider.reports.length > 5 ? 5 : reportProvider.reports.length,
                  itemBuilder: (context, index) {
                    final report = reportProvider.reports[index];
                    return ReportCardWidget(
                      report: report,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReportDetailScreen(reportId: report.id),
                          ),
                        ).then((_) {
                          _applyDateFilter(_selectedDateFilter);
                        });
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSelected = _selectedDateFilter == key;
    return GestureDetector(
      onTap: () => _applyDateFilter(key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: fg, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
