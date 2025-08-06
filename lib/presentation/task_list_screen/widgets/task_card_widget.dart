import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskCardWidget extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;

  const TaskCardWidget({
    Key? key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = task['isCompleted'] ?? false;
    final DateTime? dueDate = task['dueDate'] as DateTime?;
    final bool isOverdue =
        dueDate != null && dueDate.isBefore(DateTime.now()) && !isCompleted;
    final bool isDueToday = dueDate != null &&
        dueDate.year == DateTime.now().year &&
        dueDate.month == DateTime.now().month &&
        dueDate.day == DateTime.now().day;

    return Dismissible(
      key: Key(task['id'].toString()),
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.tertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 6.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'edit',
              color: Colors.white,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'content_copy',
              color: Colors.white,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'share',
              color: Colors.white,
              size: 6.w,
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 6.w),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 6.w,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _showQuickActionsBottomSheet(context);
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: () => _showQuickActionsBottomSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onToggleComplete,
                    child: Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : AppTheme.lightTheme.colorScheme.outline,
                          width: 2,
                        ),
                        color: isCompleted
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : Colors.transparent,
                      ),
                      child: isCompleted
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: Colors.white,
                              size: 4.w,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'] ?? 'Untitled Task',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCompleted
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                        : Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.color,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task['description'] != null &&
                            (task['description'] as String).isNotEmpty) ...[
                          SizedBox(height: 1.h),
                          Text(
                            task['description'],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (dueDate != null) ...[
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                color: isOverdue
                                    ? AppTheme.lightTheme.colorScheme.error
                                    : isDueToday
                                        ? AppTheme
                                            .lightTheme.colorScheme.primary
                                        : Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color ??
                                            Colors.grey,
                                size: 4.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                _formatDueDate(dueDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isOverdue
                                          ? AppTheme
                                              .lightTheme.colorScheme.error
                                          : isDueToday
                                              ? AppTheme.lightTheme.colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color,
                                      fontWeight: isDueToday || isOverdue
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (task['priority'] != null &&
                      task['priority'] != 'low') ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task['priority'])
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (task['priority'] as String).toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _getPriorityColor(task['priority']),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      final difference = today.difference(taskDate).inDays;
      return '$difference day${difference > 1 ? 's' : ''} overdue';
    } else {
      final difference = taskDate.difference(today).inDays;
      if (difference <= 7) {
        return 'In $difference day${difference > 1 ? 's' : ''}';
      } else {
        return '${dueDate.month}/${dueDate.day}/${dueDate.year}';
      }
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.lightTheme.colorScheme.error;
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return AppTheme.lightTheme.colorScheme.tertiary;
    }
  }

  void _showQuickActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'edit',
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                      size: 6.w,
                    ),
                    title: Text('Edit Task'),
                    onTap: () {
                      Navigator.pop(context);
                      onEdit?.call();
                    },
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'content_copy',
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                      size: 6.w,
                    ),
                    title: Text('Duplicate Task'),
                    onTap: () {
                      Navigator.pop(context);
                      onDuplicate?.call();
                    },
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'share',
                      color: Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                      size: 6.w,
                    ),
                    title: Text('Share Task'),
                    onTap: () {
                      Navigator.pop(context);
                      onShare?.call();
                    },
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'delete',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 6.w,
                    ),
                    title: Text(
                      'Delete Task',
                      style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.error),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final shouldDelete =
                          await _showDeleteConfirmation(context);
                      if (shouldDelete == true) {
                        onDelete?.call();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text(
            'Are you sure you want to delete "${task['title']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
