import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SearchableDropdownItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const SearchableDropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}

class SearchableDropdown<T> extends StatelessWidget {
  final String label;
  final String placeholder;
  final T? selectedValue;
  final List<SearchableDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const SearchableDropdown({
    super.key,
    required this.label,
    this.placeholder = 'Pilih salah satu...',
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final selectedItem = items.where((i) => i.value == selectedValue).firstOrNull;

    return FormField<T>(
      initialValue: selectedValue,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _openSearchBottomSheet(context, state),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: state.hasError ? AppColors.error : AppColors.border,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    if (selectedItem?.icon != null) ...[
                      Icon(selectedItem!.icon, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        selectedItem != null ? selectedItem.label : placeholder,
                        style: TextStyle(
                          fontSize: 14,
                          color: selectedItem != null ? AppColors.textPrimary : AppColors.textMuted,
                          fontWeight: selectedItem != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 22),
                  ],
                ),
              ),
            ),
            if (state.hasError) ...[
              const SizedBox(height: 4),
              Text(
                state.errorText ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ],
          ],
        );
      },
    );
  }

  void _openSearchBottomSheet(BuildContext context, FormFieldState<T> formState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _SearchBottomSheetContent<T>(
          title: label,
          items: items,
          selectedValue: selectedValue,
          onSelected: (val) {
            onChanged(val);
            formState.didChange(val);
            Navigator.pop(ctx);
          },
        );
      },
    );
  }
}

class _SearchBottomSheetContent<T> extends StatefulWidget {
  final String title;
  final List<SearchableDropdownItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelected;

  const _SearchBottomSheetContent({
    required this.title,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_SearchBottomSheetContent<T>> createState() => _SearchBottomSheetContentState<T>();
}

class _SearchBottomSheetContentState<T> extends State<_SearchBottomSheetContent<T>> {
  late TextEditingController _searchCtrl;
  late List<SearchableDropdownItem<T>> _filteredList;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _filteredList = widget.items;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredList = widget.items;
      } else {
        final q = query.toLowerCase();
        _filteredList = widget.items.where((i) {
          final matchesLabel = i.label.toLowerCase().contains(q);
          final matchesSub = i.subtitle?.toLowerCase().contains(q) ?? false;
          return matchesLabel || matchesSub;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filter,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Cari pilihan...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // List Items
          Expanded(
            child: _filteredList.isEmpty
                ? const Center(
                    child: Text(
                      'Pilihan tidak ditemukan',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredList.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, idx) {
                      final item = _filteredList[idx];
                      final isSelected = item.value == widget.selectedValue;

                      return ListTile(
                        onTap: () => widget.onSelected(item.value),
                        leading: item.icon != null
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryLight : AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  size: 18,
                                ),
                              )
                            : null,
                        title: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: item.subtitle != null
                            ? Text(
                                item.subtitle!,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              )
                            : null,
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
