import 'package:flutter/material.dart';
import '../presentation/task_list_screen/task_list_screen.dart';
import '../presentation/create_task_screen/create_task_screen.dart';
import '../presentation/edit_task_screen/edit_task_screen.dart';
import '../presentation/social_login_screen/social_login_screen.dart';
import '../presentation/search_tasks_screen/search_tasks_screen.dart';
import '../presentation/task_detail_screen/task_detail_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String taskList = '/task-list-screen';
  static const String createTask = '/create-task-screen';
  static const String editTask = '/edit-task-screen';
  static const String socialLogin = '/social-login-screen';
  static const String searchTasks = '/search-tasks-screen';
  static const String taskDetail = '/task-detail-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SocialLoginScreen(),
    taskList: (context) => const TaskListScreen(),
    createTask: (context) => const CreateTaskScreen(),
    editTask: (context) => const EditTaskScreen(),
    socialLogin: (context) => const SocialLoginScreen(),
    searchTasks: (context) => const SearchTasksScreen(),
    taskDetail: (context) => const TaskDetailScreen(),
    // TODO: Add your other routes here
  };
}
