import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final VoidCallback? onTap;

  const CategoryBadge({
    Key? key,
    required this.category,
    this.onTap,
  }) : super(key: key);

  Color _getCategoryColor() {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF2563EB);
      case 'personal':
        return const Color(0xFF059669);
      case 'shopping':
        return const Color(0xFFD97706);
      case 'health':
        return const Color(0xFFDC2626);
      case 'education':
        return const Color(0xFF7C3AED);
      case 'travel':
        return const Color(0xFF0891B2);
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  String _getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'work':
        return 'work';
      case 'personal':
        return 'person';
      case 'shopping':
        return 'shopping_cart';
      case 'health':
        return 'favorite';
      case 'education':
        return 'school';
      case 'travel':
        return 'flight';
      default:
        return 'label';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: _getCategoryColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: _getCategoryColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: _getCategoryIcon(),
              color: _getCategoryColor(),
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              category,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: _getCategoryColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 1.w),
              CustomIconWidget(
                iconName: 'filter_list',
                color: _getCategoryColor().withValues(alpha: 0.7),
                size: 14,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
