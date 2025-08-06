import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskFormWidget extends StatefulWidget {
  final Map<String, dynamic> taskData;
  final Function(Map<String, dynamic>) onTaskUpdated;
  final VoidCallback onCancel;

  const TaskFormWidget({
    Key? key,
    required this.taskData,
    required this.onTaskUpdated,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<TaskFormWidget> createState() => _TaskFormWidgetState();
}

class _TaskFormWidgetState extends State<TaskFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDueDate;
  String _selectedPriority = 'Medium';
  String _selectedCategory = 'Personal';
  bool _hasChanges = false;
  bool _isLoading = false;

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];
  final List<String> _categories = [
    'Personal',
    'Work',
    'Shopping',
    'Health',
    'Education'
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _titleController =
        TextEditingController(text: widget.taskData['title'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.taskData['description'] ?? '');
    _selectedDueDate = widget.taskData['dueDate'] != null
        ? DateTime.parse(widget.taskData['dueDate'])
        : null;
    _selectedPriority = widget.taskData['priority'] ?? 'Medium';
    _selectedCategory = widget.taskData['category'] ?? 'Personal';

    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  void _onPriorityChanged(String? value) {
    if (value != null && value != _selectedPriority) {
      setState(() {
        _selectedPriority = value;
        _hasChanges = true;
      });
    }
  }

  void _onCategoryChanged(String? value) {
    if (value != null && value != _selectedCategory) {
      setState(() {
        _selectedCategory = value;
        _hasChanges = true;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
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

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
        _hasChanges = true;
      });
    }
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final updatedTask = {
      ...widget.taskData,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'dueDate': _selectedDueDate?.toIso8601String(),
      'priority': _selectedPriority,
      'category': _selectedCategory,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      _isLoading = false;
    });

    widget.onTaskUpdated(updatedTask);
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return AppTheme.getSuccessColor(true);
      case 'Medium':
        return AppTheme.getWarningColor(true);
      case 'High':
        return Colors.orange;
      case 'Urgent':
        return Theme.of(context).colorScheme.error;
      default:
        return AppTheme.getWarningColor(true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Field
          Text(
            'Task Title',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Enter task title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _hasChanges &&
                          _titleController.text != widget.taskData['title']
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.getBorderColor(true),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _hasChanges &&
                          _titleController.text != widget.taskData['title']
                      ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.5)
                      : AppTheme.getBorderColor(true),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a task title';
              }
              return null;
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
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter task description (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _hasChanges &&
                          _descriptionController.text !=
                              widget.taskData['description']
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.getBorderColor(true),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _hasChanges &&
                          _descriptionController.text !=
                              widget.taskData['description']
                      ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.5)
                      : AppTheme.getBorderColor(true),
                ),
              ),
            ),
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
          InkWell(
            onTap: _selectDueDate,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _hasChanges &&
                          _selectedDueDate?.toIso8601String() !=
                              widget.taskData['dueDate']
                      ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.5)
                      : AppTheme.getBorderColor(true),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDueDate != null
                        ? '${_selectedDueDate!.month}/${_selectedDueDate!.day}/${_selectedDueDate!.year}'
                        : 'Select due date',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _selectedDueDate != null
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Priority Field
          Text(
            'Priority',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: _hasChanges &&
                        _selectedPriority != widget.taskData['priority']
                    ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.5)
                    : AppTheme.getBorderColor(true),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPriority,
                isExpanded: true,
                onChanged: _onPriorityChanged,
                items: _priorities.map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(priority),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Category Field
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: _hasChanges &&
                        _selectedCategory != widget.taskData['category']
                    ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.5)
                    : AppTheme.getBorderColor(true),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                onChanged: _onCategoryChanged,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 4.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : widget.onCancel,
                  child: Text('Cancel'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading || !_hasChanges ? null : _handleUpdate,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('Update Task'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
