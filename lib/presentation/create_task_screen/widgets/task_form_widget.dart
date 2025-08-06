import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskFormWidget extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime? selectedDate;
  final String selectedPriority;
  final String selectedCategory;
  final Function(DateTime?) onDateChanged;
  final Function(String) onPriorityChanged;
  final Function(String) onCategoryChanged;
  final VoidCallback onSave;
  final bool isLoading;
  final bool isFormValid;

  const TaskFormWidget({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedDate,
    required this.selectedPriority,
    required this.selectedCategory,
    required this.onDateChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
    required this.onSave,
    required this.isLoading,
    required this.isFormValid,
  }) : super(key: key);

  @override
  State<TaskFormWidget> createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends State<TaskFormWidget> {
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  bool _showNewCategoryField = false;
  final TextEditingController _newCategoryController = TextEditingController();

  final List<String> _categories = [
    'Work',
    'Personal',
    'Shopping',
    'Health',
    'Education',
    'Finance',
    'Travel',
    'Home',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateChanged(picked);
    }
  }

  Widget _buildPrioritySelector() {
    final priorities = [
      {'label': 'Low', 'value': 'low', 'color': AppTheme.getSuccessColor(true)},
      {
        'label': 'Medium',
        'value': 'medium',
        'color': AppTheme.getWarningColor(true)
      },
      {
        'label': 'High',
        'value': 'high',
        'color': AppTheme.lightTheme.colorScheme.error
      },
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.getBorderColor(true)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: priorities.map((priority) {
          final isSelected = widget.selectedPriority == priority['value'];
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  widget.onPriorityChanged(priority['value'] as String),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (priority['color'] as Color).withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: priority['color'] as Color, width: 2)
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: priority['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      priority['label'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? priority['color'] as Color
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.getBorderColor(true)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _categories.contains(widget.selectedCategory)
                  ? widget.selectedCategory
                  : null,
              hint: Text(
                widget.selectedCategory.isNotEmpty &&
                        !_categories.contains(widget.selectedCategory)
                    ? widget.selectedCategory
                    : 'Select Category',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              isExpanded: true,
              icon: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              items: [
                ..._categories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )),
                const DropdownMenuItem(
                  value: 'add_new',
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text('Add New Category'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == 'add_new') {
                  setState(() {
                    _showNewCategoryField = true;
                  });
                } else if (value != null) {
                  widget.onCategoryChanged(value);
                  setState(() {
                    _showNewCategoryField = false;
                  });
                }
              },
            ),
          ),
        ),
        if (_showNewCategoryField) ...[
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _newCategoryController,
                  decoration: const InputDecoration(
                    hintText: 'Enter new category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  onFieldSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      setState(() {
                        _categories.add(value.trim());
                        _showNewCategoryField = false;
                      });
                      widget.onCategoryChanged(value.trim());
                      _newCategoryController.clear();
                    }
                  },
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: () {
                  final value = _newCategoryController.text.trim();
                  if (value.isNotEmpty) {
                    setState(() {
                      _categories.add(value);
                      _showNewCategoryField = false;
                    });
                    widget.onCategoryChanged(value);
                    _newCategoryController.clear();
                  }
                },
                icon: CustomIconWidget(
                  iconName: 'check',
                  color: AppTheme.getSuccessColor(true),
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showNewCategoryField = false;
                    _newCategoryController.clear();
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Field
          Text(
            'Task Title *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: widget.titleController,
            focusNode: _titleFocusNode,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: 'Enter task title',
              prefixIcon: CustomIconWidget(
                iconName: 'task_alt',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              counterText: '${widget.titleController.text.length}/100',
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _descriptionFocusNode.requestFocus();
            },
          ),
          SizedBox(height: 3.h),

          // Description Field
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: widget.descriptionController,
            focusNode: _descriptionFocusNode,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Enter task description (optional)',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: CustomIconWidget(
                  iconName: 'description',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
              ),
              counterText: '${widget.descriptionController.text.length}/500',
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 3.h),

          // Due Date Field
          Text(
            'Due Date',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.getBorderColor(true)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      widget.selectedDate != null
                          ? '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}'
                          : 'Select due date (optional)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: widget.selectedDate != null
                                ? AppTheme.lightTheme.colorScheme.onSurface
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  if (widget.selectedDate != null)
                    GestureDetector(
                      onTap: () => widget.onDateChanged(null),
                      child: CustomIconWidget(
                        iconName: 'clear',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Priority Selector
          Text(
            'Priority',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          _buildPrioritySelector(),
          SizedBox(height: 3.h),

          // Category Dropdown
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          _buildCategoryDropdown(),
          SizedBox(height: 4.h),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isFormValid && !widget.isLoading
                  ? widget.onSave
                  : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'save',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Create Task',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
