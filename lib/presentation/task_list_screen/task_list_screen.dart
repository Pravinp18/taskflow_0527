import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/task_card_widget.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isSearchVisible = false;

  // Mock task data
  final List<Map<String, dynamic>> _allTasks = [
    {
      "id": 1,
      "title": "Complete Flutter project documentation",
      "description":
          "Write comprehensive documentation for the TaskFlow mobile application including user guides and technical specifications.",
      "isCompleted": false,
      "priority": "high",
      "dueDate": DateTime.now().add(const Duration(days: 2)),
      "createdAt": DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      "id": 2,
      "title": "Review team code submissions",
      "description":
          "Conduct thorough code review for the authentication module and provide feedback to team members.",
      "isCompleted": false,
      "priority": "medium",
      "dueDate": DateTime.now().add(const Duration(days: 1)),
      "createdAt": DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      "id": 3,
      "title": "Update project dependencies",
      "description":
          "Upgrade all Flutter packages to their latest stable versions and test compatibility.",
      "isCompleted": true,
      "priority": "low",
      "dueDate": DateTime.now().subtract(const Duration(days: 1)),
      "createdAt": DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      "id": 4,
      "title": "Prepare presentation for client meeting",
      "description":
          "Create slides showcasing the app's key features, user interface improvements, and development progress.",
      "isCompleted": false,
      "priority": "high",
      "dueDate": DateTime.now(),
      "createdAt": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": 5,
      "title": "Implement push notifications",
      "description":
          "Set up Firebase Cloud Messaging for task reminders and important updates.",
      "isCompleted": false,
      "priority": "medium",
      "dueDate": DateTime.now().add(const Duration(days: 5)),
      "createdAt": DateTime.now().subtract(const Duration(hours: 12)),
    },
    {
      "id": 6,
      "title": "Design app icon and splash screen",
      "description":
          "Create visually appealing app icon and splash screen that reflects the TaskFlow brand identity.",
      "isCompleted": true,
      "priority": "low",
      "dueDate": DateTime.now().subtract(const Duration(days: 3)),
      "createdAt": DateTime.now().subtract(const Duration(days: 7)),
    },
    {
      "id": 7,
      "title": "Optimize app performance",
      "description":
          "Profile the application and optimize memory usage, reduce loading times, and improve overall responsiveness.",
      "isCompleted": false,
      "priority": "medium",
      "dueDate": DateTime.now().add(const Duration(days: 7)),
      "createdAt": DateTime.now().subtract(const Duration(hours: 6)),
    },
    {
      "id": 8,
      "title": "Write unit tests for core features",
      "description":
          "Develop comprehensive unit tests for task management, authentication, and data persistence modules.",
      "isCompleted": false,
      "priority": "high",
      "dueDate": DateTime.now().add(const Duration(days: 4)),
      "createdAt": DateTime.now().subtract(const Duration(hours: 18)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _selectedFilter = 'all';
      _searchQuery = '';
      _searchController.clear();
      _isSearchVisible = false;
    });
  }

  List<Map<String, dynamic>> get _filteredTasks {
    List<Map<String, dynamic>> tasks = List.from(_allTasks);

    // Filter by tab
    switch (_tabController.index) {
      case 1: // Pending
        tasks = tasks.where((task) => !(task['isCompleted'] as bool)).toList();
        break;
      case 2: // Completed
        tasks = tasks.where((task) => task['isCompleted'] as bool).toList();
        break;
      default: // All Tasks
        break;
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) {
        final title = (task['title'] as String).toLowerCase();
        final description =
            (task['description'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    // Filter by priority/status
    switch (_selectedFilter) {
      case 'high':
        tasks = tasks.where((task) => task['priority'] == 'high').toList();
        break;
      case 'medium':
        tasks = tasks.where((task) => task['priority'] == 'medium').toList();
        break;
      case 'overdue':
        tasks = tasks.where((task) {
          final dueDate = task['dueDate'] as DateTime?;
          final isCompleted = task['isCompleted'] as bool;
          return dueDate != null &&
              dueDate.isBefore(DateTime.now()) &&
              !isCompleted;
        }).toList();
        break;
      case 'today':
        tasks = tasks.where((task) {
          final dueDate = task['dueDate'] as DateTime?;
          if (dueDate == null) return false;
          final now = DateTime.now();
          return dueDate.year == now.year &&
              dueDate.month == now.month &&
              dueDate.day == now.day;
        }).toList();
        break;
    }

    // Sort tasks
    tasks.sort((a, b) {
      final aCompleted = a['isCompleted'] as bool;
      final bCompleted = b['isCompleted'] as bool;

      if (aCompleted != bCompleted) {
        return aCompleted ? 1 : -1; // Incomplete tasks first
      }

      final aDueDate = a['dueDate'] as DateTime?;
      final bDueDate = b['dueDate'] as DateTime?;

      if (aDueDate != null && bDueDate != null) {
        return aDueDate.compareTo(bDueDate);
      } else if (aDueDate != null) {
        return -1;
      } else if (bDueDate != null) {
        return 1;
      }

      return (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime);
    });

    return tasks;
  }

  int get _allTasksCount => _allTasks.length;
  int get _pendingTasksCount =>
      _allTasks.where((task) => !(task['isCompleted'] as bool)).length;
  int get _completedTasksCount =>
      _allTasks.where((task) => task['isCompleted'] as bool).length;
  int get _highPriorityCount =>
      _allTasks.where((task) => task['priority'] == 'high').length;
  int get _mediumPriorityCount =>
      _allTasks.where((task) => task['priority'] == 'medium').length;
  int get _overdueCount => _allTasks.where((task) {
        final dueDate = task['dueDate'] as DateTime?;
        final isCompleted = task['isCompleted'] as bool;
        return dueDate != null &&
            dueDate.isBefore(DateTime.now()) &&
            !isCompleted;
      }).length;
  int get _todayCount => _allTasks.where((task) {
        final dueDate = task['dueDate'] as DateTime?;
        if (dueDate == null) return false;
        final now = DateTime.now();
        return dueDate.year == now.year &&
            dueDate.month == now.month &&
            dueDate.day == now.day;
      }).length;

  void _toggleTaskCompletion(Map<String, dynamic> task) {
    setState(() {
      task['isCompleted'] = !(task['isCompleted'] as bool);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task['isCompleted']
              ? 'Task marked as completed!'
              : 'Task marked as pending',
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              task['isCompleted'] = !(task['isCompleted'] as bool);
            });
          },
        ),
      ),
    );
  }

  void _deleteTask(Map<String, dynamic> task) {
    setState(() {
      _allTasks.removeWhere((t) => t['id'] == task['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task['title']}" deleted'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _allTasks.add(task);
            });
          },
        ),
      ),
    );
  }

  void _duplicateTask(Map<String, dynamic> task) {
    final newTask = Map<String, dynamic>.from(task);
    newTask['id'] = DateTime.now().millisecondsSinceEpoch;
    newTask['title'] = '${task['title']} (Copy)';
    newTask['isCompleted'] = false;
    newTask['createdAt'] = DateTime.now();

    setState(() {
      _allTasks.insert(0, newTask);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task duplicated successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareTask(Map<String, dynamic> task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${task['title']}"...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refreshTasks() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Simulate refresh - in real app, this would fetch from API
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: Text('TaskFlow'),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: CustomIconWidget(
              iconName: _isSearchVisible ? 'close' : 'search',
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/search-tasks-screen'),
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              size: 6.w,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('All Tasks'),
                  SizedBox(width: 1.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 1.5.w, vertical: 0.2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _allTasksCount.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Pending'),
                  SizedBox(width: 1.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 1.5.w, vertical: 0.2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _pendingTasksCount.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Completed'),
                  SizedBox(width: 1.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 1.5.w, vertical: 0.2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.tertiary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _completedTasksCount.toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isSearchVisible)
            SearchBarWidget(
              hintText: 'Search tasks...',
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
          Container(
            height: 8.h,
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              children: [
                FilterChipWidget(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                FilterChipWidget(
                  label: 'High Priority',
                  isSelected: _selectedFilter == 'high',
                  count: _highPriorityCount,
                  onTap: () => setState(() => _selectedFilter = 'high'),
                ),
                FilterChipWidget(
                  label: 'Medium Priority',
                  isSelected: _selectedFilter == 'medium',
                  count: _mediumPriorityCount,
                  onTap: () => setState(() => _selectedFilter = 'medium'),
                ),
                FilterChipWidget(
                  label: 'Overdue',
                  isSelected: _selectedFilter == 'overdue',
                  count: _overdueCount,
                  onTap: () => setState(() => _selectedFilter = 'overdue'),
                ),
                FilterChipWidget(
                  label: 'Due Today',
                  isSelected: _selectedFilter == 'today',
                  count: _todayCount,
                  onTap: () => setState(() => _selectedFilter = 'today'),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(filteredTasks),
                _buildTaskList(filteredTasks),
                _buildTaskList(filteredTasks),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-task-screen'),
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 7.w,
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      String title = 'No tasks found';
      String subtitle = 'Create your first task to get started with TaskFlow';

      if (_searchQuery.isNotEmpty) {
        title = 'No matching tasks';
        subtitle = 'Try adjusting your search terms or filters';
      } else if (_tabController.index == 1) {
        title = 'All caught up!';
        subtitle = 'You have no pending tasks. Great job staying organized!';
      } else if (_tabController.index == 2) {
        title = 'No completed tasks yet';
        subtitle = 'Complete some tasks to see them here';
      }

      return EmptyStateWidget(
        title: title,
        subtitle: subtitle,
        buttonText: 'Create Your First Task',
        onButtonPressed: () =>
            Navigator.pushNamed(context, '/create-task-screen'),
        imagePath:
            'https://images.unsplash.com/photo-1611224923853-80b023f02d71?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTasks,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 20.h),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCardWidget(
            task: task,
            onTap: () => Navigator.pushNamed(
              context,
              '/task-detail-screen',
              arguments: task,
            ),
            onToggleComplete: () => _toggleTaskCompletion(task),
            onEdit: () => Navigator.pushNamed(
              context,
              '/edit-task-screen',
              arguments: task,
            ),
            onDelete: () => _deleteTask(task),
            onDuplicate: () => _duplicateTask(task),
            onShare: () => _shareTask(task),
          );
        },
      ),
    );
  }
}
