import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterChipsWidget extends StatelessWidget {
  final Map<String, dynamic> activeFilters;
  final VoidCallback onClearFilters;
  final Function(String) onRemoveFilter;

  const FilterChipsWidget({
    Key? key,
    required this.activeFilters,
    required this.onClearFilters,
    required this.onRemoveFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activeFilters.isEmpty) {
      return SizedBox.shrink();
    }

    List<Widget> filterChips = [];

    activeFilters.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        String displayText = _getDisplayText(key, value);
        filterChips.add(
          Container(
            margin: EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                displayText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              deleteIcon: CustomIconWidget(
                iconName: 'close',
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
              onDeleted: () => onRemoveFilter(key),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      }
    });

    if (filterChips.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Filters (${filterChips.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              TextButton(
                onPressed: onClearFilters,
                child: Text(
                  'Clear All',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: filterChips,
          ),
        ),
      ],
    );
  }

  String _getDisplayText(String key, dynamic value) {
    switch (key) {
      case 'status':
        return value == 'completed' ? 'Completed' : 'Pending';
      case 'priority':
        return 'Priority: ${value.toString().toUpperCase()}';
      case 'dateRange':
        return 'Date Range';
      case 'category':
        return 'Category: $value';
      default:
        return '$key: $value';
    }
  }
}
