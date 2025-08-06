import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentSearchesWidget extends StatelessWidget {
  final List<String> recentSearches;
  final Function(String) onSearchTap;
  final Function(String) onRemoveSearch;

  const RecentSearchesWidget({
    Key? key,
    required this.recentSearches,
    required this.onSearchTap,
    required this.onRemoveSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent Searches',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final search = recentSearches[index];
              return Container(
                margin: EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    search,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  deleteIcon: CustomIconWidget(
                    iconName: 'close',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  onDeleted: () => onRemoveSearch(search),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
