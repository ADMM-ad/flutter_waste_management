import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/report_provider.dart';
import '../../widgets/report_card_widget.dart';
import '../../widgets/skeletons/report_card_skeleton.dart';
import 'create_report_screen.dart';
import 'report_detail_screen.dart';

class ReportHistoryScreen extends StatefulWidget {
  final bool isNested;
  const ReportHistoryScreen({super.key, this.isNested = false});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _statusTabs = [
    {'label': 'Semua', 'value': 'all', 'icon': Icons.list_alt_rounded},
    {'label': 'Menunggu', 'value': 'pending', 'icon': Icons.hourglass_top_rounded},
    {'label': 'Diproses', 'value': 'in_progress', 'icon': Icons.sync_rounded},
    {'label': 'Selesai', 'value': 'completed', 'icon': Icons.check_circle_rounded},
    {'label': 'Ditolak', 'value': 'rejected', 'icon': Icons.cancel_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final reportProvider = Provider.of<ReportProvider>(context, listen: false);
        reportProvider.loadMoreReports();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      reportProvider.fetchReports(refresh: true, status: 'all');
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final selectedStatus = _statusTabs[_tabController.index]['value']!;
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    reportProvider.fetchReports(refresh: true, status: selectedStatus);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Laporan Sampah'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: _statusTabs.map((t) => Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t['icon'] as IconData, size: 16),
                const SizedBox(width: 6),
                Text(t['label'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          )).toList(),
        ),
      ),
      floatingActionButton: widget.isNested
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateReportScreen()),
                );
              },
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          final selectedStatus = _statusTabs[_tabController.index]['value']!;
          await reportProvider.fetchReports(refresh: true, status: selectedStatus);
        },
        child: reportProvider.isLoadingReports
            ? ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 4,
                itemBuilder: (_, __) => const ReportCardSkeleton(),
              )
            : reportProvider.reports.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Tidak ada laporan pada kategori ini',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: reportProvider.reports.length + (reportProvider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == reportProvider.reports.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

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
      ),
    );
  }
}
