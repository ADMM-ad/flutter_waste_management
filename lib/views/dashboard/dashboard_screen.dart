import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      reportProvider.fetchCategories();
      reportProvider.fetchReports(refresh: true);
    });
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
          await reportProvider.fetchReports(refresh: true);
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
                    colors: [Color(0xFF15803D), Color(0xFF166534)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temukan Timbunan Sampah?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Foto, deteksi otomatis jenis sampah dengan AI, dan kirimkan titik lokasi untuk ditindaklanjuti petugas.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateReportScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.add_a_photo, size: 18),
                      label: const Text('Buat Laporan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Summary Stats Row (Skeleton Loading if fetching)
              if (reportProvider.isLoadingReports)
                const DashboardStatsSkeleton()
              else
                Row(
                  children: [
                    _buildStatCard('Menunggu', pendingCount.toString(), AppColors.pendingBg, AppColors.pending),
                    const SizedBox(width: 10),
                    _buildStatCard('Diproses', processCount.toString(), AppColors.inProgressBg, AppColors.inProgress),
                    const SizedBox(width: 10),
                    _buildStatCard('Selesai', completedCount.toString(), AppColors.completedBg, AppColors.completed),
                  ],
                ),

              const SizedBox(height: 24),

              // Recent Reports Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Laporan Terakhir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReportHistoryScreen()),
                      );
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Reports List Preview (Skeleton Loading if fetching)
              if (reportProvider.isLoadingReports)
                Column(
                  children: List.generate(3, (_) => const ReportCardSkeleton()),
                )
              else if (reportProvider.reports.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        'Belum ada laporan yang dikirimkan.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
                        );
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

  Widget _buildStatCard(String label, String value, Color bg, Color fg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fg.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
