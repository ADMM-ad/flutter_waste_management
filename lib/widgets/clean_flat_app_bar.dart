import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CleanFlatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const CleanFlatAppBar({
    super.key,
    required this.userName,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // Logo / Brand Icon Box
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Greeting & Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $userName',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Warga Peduli Lingkungan',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Avatar with Modern Popup Menu
              Theme(
                data: Theme.of(context).copyWith(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
                child: PopupMenuButton<String>(
                  tooltip: 'Menu Akun',
                  offset: const Offset(0, 48),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'profile') {
                      onProfileTap();
                    } else if (value == 'logout') {
                      onLogoutTap();
                    }
                  },
                  itemBuilder: (BuildContext ctx) => [
                    // Item 1: Profile
                    PopupMenuItem<String>(
                      value: 'profile',
                      height: 42,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 19,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Profil Saya',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    // Item 2: Logout
                    PopupMenuItem<String>(
                      value: 'logout',
                      height: 42,
                      child: Row(
                        children: const [
                          Icon(
                            Icons.logout_rounded,
                            size: 19,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Keluar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getInitials(userName),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
