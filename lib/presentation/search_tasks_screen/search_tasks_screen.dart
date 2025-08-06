import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_search_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/task_search_result_widget.dart';

class SearchTasksScreen extends StatefulWidget {
  const SearchTasksScreen({Key? key}) : super(key: key);

  @override
  State<SearchTasksScreen> createState() => _SearchTasksScreenState();
}

class _SearchTasksScreenState extends State<SearchTasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<String> _recentSearches = [
    'meeting notes',
    'urgent tasks',
    'project deadline',
    'call client',
  ];

  Map<String, dynamic> _activeFilters = {};
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // Mock task data
  final List<Map<String, dynamic>> _allTasks = [
    {
      "id": 1,
      "title": "Complete project proposal",
      "description":
          "Finish the quarterly project proposal for the marketing campaign and submit to management team",
      "isCompleted": false,
      "priority": "high",
      "dueDate": "2025-08-07T10:00:00.000Z",
      "category": "Work",
      "createdAt": "2025-08-05T09:56:04.223Z"
    },
    {
      "id": 2,
      "title": "Schedule team meeting",
      "description":
          "Organize weekly team sync meeting to discuss project progress and upcoming deadlines",
      "isCompleted": true,
      "priority": "medium",
      "dueDate": "2025-08-06T14:30:00.000Z",
      "category": "Work",
      "createdAt": "2025-08-04T15:20:00.000Z"
    },
    {
      "id": 3,
      "title": "Review client feedback",
      "description":
          "Go through client comments on the latest design mockups and prepare revision notes",
      "isCompleted": false,
      "priority": "high",
      "dueDate": "2025-08-08T16:00:00.000Z",
      "category": "Design",
      "createdAt": "2025-08-03T11:45:00.000Z"
    },
    {
      "id": 4,
      "title": "Update documentation",
      "description":
          "Revise API documentation with latest endpoint changes and examples",
      "isCompleted": false,
      "priority": "low",
      "dueDate": "2025-08-10T12:00:00.000Z",
      "category": "Development",
      "createdAt": "2025-08-02T09:30:00.000Z"
    },
    {
      "id": 5,
      "title": "Call insurance company",
      "description":
          "Contact insurance provider to discuss policy renewal and coverage options",
      "isCompleted": false,
      "priority": "medium",
      "dueDate": "2025-08-09T11:00:00.000Z",
      "category": "Personal",
      "createdAt": "2025-08-01T14:15:00.000Z"
    },
    {
      "id": 6,
      "title": "Grocery shopping",
      "description":
          "Buy weekly groceries including fresh vegetables, dairy products, and household items",
      "isCompleted": true,
      "priority": "low",
      "dueDate": "2025-08-05T18:00:00.000Z",
      "category": "Personal",
      "createdAt": "2025-08-05T08:00:00.000Z"
    },
    {
      "id": 7,
      "title": "Prepare presentation slides",
      "description":
          "Create compelling slides for next week's client presentation including charts and mockups",
      "isCompleted": false,
      "priority": "high",
      "dueDate": "2025-08-12T09:00:00.000Z",
      "category": "Work",
      "createdAt": "2025-07-30T16:45:00.000Z"
    },
    {
      "id": 8,
      "title": "Book dentist appointment",
      "description":
          "Schedule routine dental checkup and cleaning for next month",
      "isCompleted": false,
      "priority": "medium",
      "dueDate": "2025-08-15T10:30:00.000Z",
      "category": "Health",
      "createdAt": "2025-07-28T13:20:00.000Z"
    }
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
    _performSearch(_searchController.text);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    List<Map<String, dynamic>> results = _allTasks.where((task) {
      final title = (task['title'] as String).toLowerCase();
      final description = (task['description'] as String).toLowerCase();
      final searchQuery = query.toLowerCase();

      bool matchesText =
          title.contains(searchQuery) || description.contains(searchQuery);

      if (!matchesText) return false;

      // Apply filters
      if (_activeFilters['status'] != null) {
        final isCompleted = task['isCompleted'] as bool;
        if (_activeFilters['status'] == 'completed' && !isCompleted)
          return false;
        if (_activeFilters['status'] == 'pending' && isCompleted) return false;
      }

      if (_activeFilters['priority'] != null) {
        if (task['priority'] != _activeFilters['priority']) return false;
      }

      if (_activeFilters['dateRange'] != null) {
        final dateRange = _activeFilters['dateRange'] as Map<String, dynamic>;
        final taskDueDate = DateTime.tryParse(task['dueDate'].toString());
        if (taskDueDate != null) {
          final startDate = DateTime.parse(dateRange['start']);
          final endDate = DateTime.parse(dateRange['end']);
          if (taskDueDate.isBefore(startDate) || taskDueDate.isAfter(endDate)) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
  }

  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _onRecentSearchTap(String search) {
    _searchController.text = search;
    _addToRecentSearches(search);
    _performSearch(search);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _performSearch(_searchController.text);
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
    });
    _performSearch(_searchController.text);
  }

  void _removeFilter(String key) {
    setState(() {
      _activeFilters.remove(key);
    });
    _performSearch(_searchController.text);
  }

  void _onTaskTap(Map<String, dynamic> task) {
    _addToRecentSearches(_searchController.text);
    Navigator.pushNamed(
      context,
      '/task-detail-screen',
      arguments: task,
    );
  }

  void _onTaskDismissed(Map<String, dynamic> task, DismissDirection direction) {
    setState(() {
      _searchResults.removeWhere((t) => t['id'] == task['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task['title']}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _searchResults.add(task);
            });
          },
        ),
      ),
    );
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _addToRecentSearches(suggestion);
    _performSearch(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).appBarTheme.foregroundColor,
            size: 24,
          ),
        ),
        title: SearchBarWidget(
          controller: _searchController,
          onChanged: (value) {
            // Handled by listener
          },
          onClear: _clearSearch,
          autofocus: true,
        ),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'filter_list',
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  size: 24,
                ),
                if (_activeFilters.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          FilterChipsWidget(
            activeFilters: _activeFilters,
            onClearFilters: _clearAllFilters,
            onRemoveFilter: _removeFilter,
          ),

          // Recent searches (only show when not searching)
          if (!_isSearching)
            RecentSearchesWidget(
              recentSearches: _recentSearches,
              onSearchTap: _onRecentSearchTap,
              onRemoveSearch: _removeRecentSearch,
            ),

          // Search results or empty state
          Expanded(
            child: _isSearching
                ? _searchResults.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final task = _searchResults[index];
                          return TaskSearchResultWidget(
                            task: task,
                            searchQuery: _searchController.text,
                            onTap: () => _onTaskTap(task),
                            onDismissed: (direction) =>
                                _onTaskDismissed(task, direction),
                          );
                        },
                      )
                    : EmptySearchStateWidget(
                        searchQuery: _searchController.text,
                        hasFilters: _activeFilters.isNotEmpty,
                        onClearFilters: _clearAllFilters,
                        onSuggestionTap: _onSuggestionTap,
                      )
                : EmptySearchStateWidget(
                    searchQuery: '',
                    hasFilters: false,
                    onClearFilters: _clearAllFilters,
                    onSuggestionTap: _onSuggestionTap,
                  ),
          ),
        ],
      ),
    );
  }
}
