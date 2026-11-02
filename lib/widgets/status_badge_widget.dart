import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String status;

  const StatusBadgeWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'diproses':
        bg = AppColors.inProgressBg;
        fg = AppColors.inProgress;
        label = 'Diproses';
        break;
      case 'completed':
      case 'selesai':
        bg = AppColors.completedBg;
        fg = AppColors.completed;
        label = 'Selesai';
        break;
      case 'rejected':
      case 'ditolak':
        bg = AppColors.rejectedBg;
        fg = AppColors.rejected;
        label = 'Ditolak';
        break;
      case 'pending':
      case 'menunggu':
      default:
        bg = AppColors.pendingBg;
        fg = AppColors.pending;
        label = 'Menunggu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
