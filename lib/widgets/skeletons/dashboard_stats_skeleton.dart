import 'package:flutter/material.dart';
import '../skeleton_loader.dart';

class DashboardStatsSkeleton extends StatelessWidget {
  const DashboardStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : 4,
                right: index == 2 ? 0 : 4,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: const [
                  SkeletonBox(width: 32, height: 24, borderRadius: 6),
                  SizedBox(height: 8),
                  SkeletonBox(width: 50, height: 12, borderRadius: 4),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
