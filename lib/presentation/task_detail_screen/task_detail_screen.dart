import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/category_badge.dart';
import './widgets/due_date_section.dart';
import './widgets/priority_indicator.dart';
import './widgets/task_context_menu.dart';
import './widgets/task_status_toggle.dart';
import './widgets/task_timestamps.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({Key? key}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  bool _showContextMenu = false;
  OverlayEntry? _overlayEntry;

  // Mock task data
  final Map<String, dynamic> taskData = {
    "id": 1,
    "title": "Complete Flutter TaskFlow App Development",
    "description":
        """Finalize the development of the TaskFlow mobile application with all core features including task management, social authentication, and responsive UI design. 

Key deliverables:
• Implement task CRUD operations
• Add social login integration
• Design responsive mobile interface
• Test across different screen sizes
• Optimize performance and user experience

This is a high-priority project that requires attention to detail and adherence to modern mobile development best practices.""",
    "isCompleted": false,
    "priority": "High",
    "category": "Work",
    "dueDate": DateTime.now().add(const Duration(days: 3)),
    "createdAt": DateTime.now().subtract(const Duration(days: 5)),
    "modifiedAt": DateTime.now().subtract(const Duration(hours: 2)),
  };

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    // Animate FAB entrance
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _toggleTaskCompletion(bool isCompleted) {
    setState(() {
      taskData['isCompleted'] = isCompleted;
      taskData['modifiedAt'] = DateTime.now();
    });

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCompleted
              ? 'Task marked as completed!'
              : 'Task marked as incomplete',
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToEditTask() {
    Navigator.pushNamed(context, '/edit-task-screen');
  }

  void _showTaskContextMenu(BuildContext context, TapDownDetails details) {
    if (_showContextMenu) {
      _removeOverlay();
      return;
    }

    _showContextMenu = true;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.globalToLocal(details.globalPosition);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _removeOverlay,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          Positioned(
            left: position.dx - 40.w,
            top: position.dy + 2.h,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 40.w,
                child: TaskContextMenu(
                  taskTitle: taskData['title'] as String,
                  taskDescription: taskData['description'] as String,
                  onDismiss: _removeOverlay,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showContextMenu = false;
  }

  void _filterByCategory() {
    Navigator.pushNamed(context, '/task-list-screen');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtering tasks by ${taskData['category']} category'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Task Details',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            onPressed: _navigateToEditTask,
            icon: CustomIconWidget(
              iconName: 'edit',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Toggle and Priority Row
                    Row(
                      children: [
                        TaskStatusToggle(
                          isCompleted: taskData['isCompleted'] as bool,
                          onToggle: _toggleTaskCompletion,
                        ),
                        const Spacer(),
                        PriorityIndicator(
                          priority: taskData['priority'] as String,
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),

                    // Task Title
                    GestureDetector(
                      onTapDown: (details) =>
                          _showTaskContextMenu(context, details),
                      child: Text(
                        taskData['title'] as String,
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: (taskData['isCompleted'] as bool)
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Category Badge
                    CategoryBadge(
                      category: taskData['category'] as String,
                      onTap: _filterByCategory,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Description Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'description',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Description',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    GestureDetector(
                      onTapDown: (details) =>
                          _showTaskContextMenu(context, details),
                      child: Text(
                        taskData['description'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Due Date Section
              DueDateSection(
                dueDate: taskData['dueDate'] as DateTime?,
              ),

              SizedBox(height: 3.h),

              // Timestamps Section
              TaskTimestamps(
                createdAt: taskData['createdAt'] as DateTime,
                modifiedAt: taskData['modifiedAt'] as DateTime?,
              ),

              SizedBox(height: 10.h), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _navigateToEditTask,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              icon: CustomIconWidget(
                iconName: 'edit',
                color: Colors.white,
                size: 20,
              ),
              label: Text(
                'Edit Task',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
