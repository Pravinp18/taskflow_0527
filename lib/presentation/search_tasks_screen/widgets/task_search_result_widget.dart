import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TaskSearchResultWidget extends StatelessWidget {
  final Map<String, dynamic> task;
  final String searchQuery;
  final VoidCallback onTap;
  final Function(DismissDirection) onDismissed;

  const TaskSearchResultWidget({
    Key? key,
    required this.task,
    required this.searchQuery,
    required this.onTap,
    required this.onDismissed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = task['isCompleted'] ?? false;
    final String title = task['title'] ?? '';
    final String description = task['description'] ?? '';
    final String priority = task['priority'] ?? 'medium';
    final DateTime? dueDate = task['dueDate'] != null
        ? DateTime.tryParse(task['dueDate'].toString())
        : null;

    return Dismissible(
      key: Key(task['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: onDismissed,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: CustomIconWidget(
          iconName: 'delete',
          color: Theme.of(context).colorScheme.onError,
          size: 24,
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                        color: isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                      child: isCompleted
                          ? CustomIconWidget(
                              iconName: 'check',
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 14,
                            )
                          : null,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildHighlightedText(
                        title,
                        searchQuery,
                        Theme.of(context).textTheme.titleMedium!,
                        context,
                      ),
                    ),
                    _buildPriorityIndicator(priority, context),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 32),
                    child: _buildHighlightedText(
                      description,
                      searchQuery,
                      Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      context,
                    ),
                  ),
                ],
                if (dueDate != null) ...[
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 32),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: _getDueDateColor(dueDate, context),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatDueDate(dueDate),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _getDueDateColor(dueDate, context),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
      String text, String query, TextStyle style, BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: style.copyWith(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildPriorityIndicator(String priority, BuildContext context) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'high':
        color = Theme.of(context).colorScheme.error;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
        color = Theme.of(context).colorScheme.tertiary;
        break;
      default:
        color = Theme.of(context).colorScheme.outline;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Color _getDueDateColor(DateTime dueDate, BuildContext context) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return Theme.of(context).colorScheme.error;
    } else if (difference <= 1) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due ${dueDate.month}/${dueDate.day}/${dueDate.year}';
    }
  }
}
