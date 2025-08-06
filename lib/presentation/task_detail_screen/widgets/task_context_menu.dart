import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskContextMenu extends StatelessWidget {
  final String taskTitle;
  final String taskDescription;
  final VoidCallback onDismiss;

  const TaskContextMenu({
    Key? key,
    required this.taskTitle,
    required this.taskDescription,
    required this.onDismiss,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    onDismiss();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareTask(BuildContext context) {
    final shareText = 'Task: $taskTitle\n\nDescription: $taskDescription';
    // In a real implementation, you would use share_plus package
    // For now, we'll copy to clipboard as fallback
    _copyToClipboard(context, shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMenuItem(
            context,
            icon: 'content_copy',
            title: 'Copy Title',
            onTap: () => _copyToClipboard(context, taskTitle),
          ),
          Divider(
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildMenuItem(
            context,
            icon: 'content_copy',
            title: 'Copy Description',
            onTap: () => _copyToClipboard(context, taskDescription),
          ),
          Divider(
            height: 1,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildMenuItem(
            context,
            icon: 'share',
            title: 'Share Task',
            onTap: () => _shareTask(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
