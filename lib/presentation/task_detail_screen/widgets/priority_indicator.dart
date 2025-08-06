import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PriorityIndicator extends StatelessWidget {
  final String priority;

  const PriorityIndicator({
    Key? key,
    required this.priority,
  }) : super(key: key);

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFDC2626);
      case 'medium':
        return const Color(0xFFD97706);
      case 'low':
        return const Color(0xFF059669);
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getPriorityIcon() {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'keyboard_double_arrow_up';
      case 'medium':
        return 'keyboard_arrow_up';
      case 'low':
        return 'keyboard_arrow_down';
      default:
        return 'remove';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: _getPriorityColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getPriorityColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: _getPriorityIcon(),
            color: _getPriorityColor(),
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            priority.toUpperCase(),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: _getPriorityColor(),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
