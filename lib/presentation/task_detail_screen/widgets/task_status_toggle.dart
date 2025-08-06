import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskStatusToggle extends StatefulWidget {
  final bool isCompleted;
  final Function(bool) onToggle;

  const TaskStatusToggle({
    Key? key,
    required this.isCompleted,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<TaskStatusToggle> createState() => _TaskStatusToggleState();
}

class _TaskStatusToggleState extends State<TaskStatusToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    HapticFeedback.lightImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onToggle(!widget.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleToggle,
            child: Container(
              width: 20.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: widget.isCompleted
                    ? AppTheme.lightTheme.colorScheme.tertiary
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isCompleted
                      ? AppTheme.lightTheme.colorScheme.tertiary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.isCompleted
                    ? Center(
                        key: const ValueKey('completed'),
                        child: CustomIconWidget(
                          iconName: 'check',
                          color: Colors.white,
                          size: 24,
                        ),
                      )
                    : Center(
                        key: const ValueKey('incomplete'),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
