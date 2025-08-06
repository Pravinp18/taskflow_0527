import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/delete_confirmation_dialog.dart';
import './widgets/task_form_widget.dart';
import './widgets/unsaved_changes_dialog.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({Key? key}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  bool _hasUnsavedChanges = false;
  bool _isDeleting = false;

  // Mock task data - in real app this would come from arguments or state management
  final Map<String, dynamic> _taskData = {
    "id": 1,
    "title": "Complete Flutter Project",
    "description":
        "Finish the TaskFlow mobile application with all required features including social authentication, CRUD operations, and responsive design.",
    "dueDate": "2025-08-15T23:59:59.000Z",
    "priority": "High",
    "category": "Work",
    "isCompleted": false,
    "createdAt": "2025-08-05T09:54:42.050Z",
    "updatedAt": "2025-08-05T09:54:42.050Z"
  };

  void _handleTaskUpdate(Map<String, dynamic> updatedTask) {
    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.getSuccessColor(true),
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text('Task updated successfully'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Navigate back to task detail screen
    Navigator.pushReplacementNamed(context, '/task-detail-screen');
  }

  void _handleCancel() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.pop(context);
    }
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UnsavedChangesDialog(
        onSave: () {
          Navigator.pop(context);
          // Trigger form save - this would be handled by the form widget
        },
        onDiscard: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteConfirmationDialog(
        taskTitle: _taskData['title'] ?? 'Untitled Task',
        onConfirm: _handleDelete,
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleDelete() async {
    Navigator.pop(context); // Close dialog

    setState(() {
      _isDeleting = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'delete',
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text('Task deleted successfully'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Navigate back to task list
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/task-list-screen',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: _handleCancel,
          icon: CustomIconWidget(
            iconName: 'close',
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            size: 24,
          ),
        ),
        title: Text(
          'Edit Task',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        actions: [
          if (_hasUnsavedChanges)
            Container(
              margin: EdgeInsets.only(right: 4.w),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Task Form
                    TaskFormWidget(
                      taskData: _taskData,
                      onTaskUpdated: _handleTaskUpdate,
                      onCancel: _handleCancel,
                    ),

                    SizedBox(height: 4.h),

                    // Delete Button
                    Container(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isDeleting ? null : _showDeleteConfirmation,
                        icon: _isDeleting
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              )
                            : CustomIconWidget(
                                iconName: 'delete',
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                        label: Text(
                          _isDeleting ? 'Deleting...' : 'Delete Task',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
