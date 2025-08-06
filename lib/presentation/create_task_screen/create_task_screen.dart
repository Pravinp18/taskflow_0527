import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/task_form_widget.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedPriority = 'medium';
  String _selectedCategory = 'Personal';
  bool _isLoading = false;
  bool _isDraftSaved = false;

  // Mock data for existing tasks to prevent duplicates
  final List<Map<String, dynamic>> _existingTasks = [
    {
      "id": 1,
      "title": "Complete project proposal",
      "description":
          "Finish the quarterly project proposal and submit to management for review",
      "dueDate": DateTime.now().add(const Duration(days: 3)),
      "priority": "high",
      "category": "Work",
      "isCompleted": false,
      "createdAt": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "id": 2,
      "title": "Buy groceries",
      "description": "Get milk, bread, eggs, and vegetables for the week",
      "dueDate": DateTime.now().add(const Duration(days: 1)),
      "priority": "medium",
      "category": "Shopping",
      "isCompleted": false,
      "createdAt": DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      "id": 3,
      "title": "Schedule dentist appointment",
      "description": "Call Dr. Smith's office to schedule routine cleaning",
      "dueDate": DateTime.now().add(const Duration(days: 7)),
      "priority": "low",
      "category": "Health",
      "isCompleted": true,
      "createdAt": DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _loadDraftIfExists();
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
    _saveDraft();
  }

  void _loadDraftIfExists() {
    // Simulate loading draft from local storage
    // In real implementation, this would load from SharedPreferences or local database
    setState(() {
      _titleController.text = "";
      _descriptionController.text = "";
    });
  }

  void _saveDraft() {
    if (_titleController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty) {
      // Simulate saving draft to local storage
      setState(() {
        _isDraftSaved = true;
      });
    }
  }

  void _clearDraft() {
    // Simulate clearing draft from local storage
    setState(() {
      _isDraftSaved = false;
    });
  }

  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty;
  }

  bool _isDuplicateTask(String title) {
    return (_existingTasks as List).any((dynamic task) =>
        (task as Map<String, dynamic>)["title"].toString().toLowerCase() ==
        title.toLowerCase());
  }

  Future<void> _saveTask() async {
    if (!_isFormValid || _isLoading) return;

    final title = _titleController.text.trim();

    // Check for duplicate tasks
    if (_isDuplicateTask(title)) {
      _showErrorDialog('Duplicate Task',
          'A task with this title already exists. Please choose a different title.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Create new task object
      final newTask = {
        "id": _existingTasks.length + 1,
        "title": title,
        "description": _descriptionController.text.trim(),
        "dueDate": _selectedDate,
        "priority": _selectedPriority,
        "category": _selectedCategory,
        "isCompleted": false,
        "createdAt": DateTime.now(),
      };

      // Add to existing tasks (simulate saving to database)
      _existingTasks.add(newTask);

      // Provide haptic feedback
      HapticFeedback.mediumImpact();

      // Clear draft
      _clearDraft();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.getSuccessColor(true),
                  size: 20,
                ),
                SizedBox(width: 2.w),
                const Text('Task created successfully!'),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate back to task list
        Navigator.pop(context, newTask);
      }
    } catch (e) {
      // Handle network or other errors
      if (mounted) {
        _showErrorDialog('Error',
            'Failed to create task. Please check your connection and try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_titleController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
              'You have unsaved changes. Do you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _clearDraft();
                Navigator.pop(context, true);
              },
              child: Text(
                'Discard',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Task',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (_isDraftSaved)
                Text(
                  'Draft saved',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.getSuccessColor(true),
                      ),
                ),
            ],
          ),
          actions: [
            if (_titleController.text.trim().isNotEmpty ||
                _descriptionController.text.trim().isNotEmpty)
              TextButton(
                onPressed: () {
                  _titleController.clear();
                  _descriptionController.clear();
                  setState(() {
                    _selectedDate = null;
                    _selectedPriority = 'medium';
                    _selectedCategory = 'Personal';
                  });
                  _clearDraft();
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(width: 2.w),
          ],
        ),
        body: SafeArea(
          child: TaskFormWidget(
            titleController: _titleController,
            descriptionController: _descriptionController,
            selectedDate: _selectedDate,
            selectedPriority: _selectedPriority,
            selectedCategory: _selectedCategory,
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
            onPriorityChanged: (priority) {
              setState(() {
                _selectedPriority = priority;
              });
            },
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            onSave: _saveTask,
            isLoading: _isLoading,
            isFormValid: _isFormValid,
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: AppTheme.getBorderColor(true),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Fields marked with * are required',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                if (_isDraftSaved)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.getSuccessColor(true).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'save',
                          color: AppTheme.getSuccessColor(true),
                          size: 12,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Auto-saved',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.getSuccessColor(true),
                                    fontSize: 10.sp,
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
