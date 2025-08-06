import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheetWidget({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    if (_filters['dateRange'] != null) {
      final dateRange = _filters['dateRange'] as Map<String, dynamic>;
      _selectedDateRange = DateTimeRange(
        start: DateTime.parse(dateRange['start']),
        end: DateTime.parse(dateRange['end']),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Tasks',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Status Filter
          _buildSectionTitle('Status'),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  'All',
                  _filters['status'] == null,
                  () => setState(() => _filters['status'] = null),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  'Pending',
                  _filters['status'] == 'pending',
                  () => setState(() => _filters['status'] = 'pending'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  'Completed',
                  _filters['status'] == 'completed',
                  () => setState(() => _filters['status'] = 'completed'),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Priority Filter
          _buildSectionTitle('Priority'),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  'All',
                  _filters['priority'] == null,
                  () => setState(() => _filters['priority'] = null),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  'High',
                  _filters['priority'] == 'high',
                  () => setState(() => _filters['priority'] = 'high'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  'Medium',
                  _filters['priority'] == 'medium',
                  () => setState(() => _filters['priority'] = 'medium'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  'Low',
                  _filters['priority'] == 'low',
                  () => setState(() => _filters['priority'] = 'low'),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Date Range Filter
          _buildSectionTitle('Due Date Range'),
          SizedBox(height: 8),
          InkWell(
            onTap: _selectDateRange,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'date_range',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDateRange != null
                          ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                          : 'Select date range',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _selectedDateRange != null
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                    ),
                  ),
                  if (_selectedDateRange != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDateRange = null;
                          _filters.remove('dateRange');
                        });
                      },
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filters.clear();
                      _selectedDateRange = null;
                    });
                  },
                  child: Text('Clear All'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedDateRange != null) {
                      _filters['dateRange'] = {
                        'start': _selectedDateRange!.start.toIso8601String(),
                        'end': _selectedDateRange!.end.toIso8601String(),
                      };
                    }
                    widget.onApplyFilters(_filters);
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filters'),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Theme.of(context).colorScheme.primary)
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
