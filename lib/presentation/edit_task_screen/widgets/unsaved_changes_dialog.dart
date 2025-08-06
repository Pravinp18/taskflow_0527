import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UnsavedChangesDialog extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final VoidCallback onCancel;

  const UnsavedChangesDialog({
    Key? key,
    required this.onSave,
    required onDiscard,
    required this.onCancel,
  })  : onDiscard = onDiscard,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'info',
            color: AppTheme.getWarningColor(true),
            size: 24,
          ),
          SizedBox(width: 3.w),
          Text(
            'Unsaved Changes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have unsaved changes to this task.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 2.h),
          Text(
            'What would you like to do?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Continue Editing',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        TextButton(
          onPressed: onDiscard,
          child: Text(
            'Discard Changes',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onSave,
          child: Text('Save Changes'),
        ),
      ],
    );
  }
}
