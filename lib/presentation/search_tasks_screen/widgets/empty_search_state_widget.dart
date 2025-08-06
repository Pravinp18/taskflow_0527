import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptySearchStateWidget extends StatelessWidget {
  final String searchQuery;
  final bool hasFilters;
  final VoidCallback onClearFilters;
  final Function(String) onSuggestionTap;

  const EmptySearchStateWidget({
    Key? key,
    required this.searchQuery,
    required this.hasFilters,
    required this.onClearFilters,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> suggestions = [
      'meeting',
      'urgent',
      'project',
      'call',
      'review',
      'deadline',
    ];

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: searchQuery.isEmpty ? 'search' : 'search_off',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 24),
            Text(
              searchQuery.isEmpty
                  ? 'Start typing to search tasks'
                  : 'No tasks found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              searchQuery.isEmpty
                  ? 'Search by task title, description, or keywords'
                  : hasFilters
                      ? 'Try adjusting your filters or search terms'
                      : 'Try different keywords or check your spelling',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters && searchQuery.isNotEmpty) ...[
              SizedBox(height: 24),
              OutlinedButton(
                onPressed: onClearFilters,
                child: Text('Clear Filters'),
              ),
            ],
            if (searchQuery.isEmpty) ...[
              SizedBox(height: 32),
              Text(
                'Popular searches:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions.map((suggestion) {
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: () => onSuggestionTap(suggestion),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    side: BorderSide.none,
                    labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
