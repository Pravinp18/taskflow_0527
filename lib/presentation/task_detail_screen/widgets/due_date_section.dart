import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DueDateSection extends StatelessWidget {
  final DateTime? dueDate;

  const DueDateSection({
    Key? key,
    required this.dueDate,
  }) : super(key: key);

  bool get _isOverdue {
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  String get _formattedDate {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;

    if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference == -1) {
      return 'Due yesterday';
    } else if (difference > 1) {
      return 'Due in $difference days';
    } else {
      return 'Overdue by ${-difference} days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _isOverdue
            ? const Color(0xFFDC2626).withValues(alpha: 0.05)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isOverdue
              ? const Color(0xFFDC2626).withValues(alpha: 0.2)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _isOverdue
                  ? const Color(0xFFDC2626).withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'calendar_today',
              color: _isOverdue
                  ? const Color(0xFFDC2626)
                  : AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due Date',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formattedDate,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: _isOverdue
                        ? const Color(0xFFDC2626)
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (dueDate != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_isOverdue)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'OVERDUE',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
