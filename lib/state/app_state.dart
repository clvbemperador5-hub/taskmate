import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

enum FocusMode {
  pomodoro('FOCUS TIME', 1500, 'Pomodoro'),
  shortBreak('SHORT BREAK', 300, 'Short Break'),
  longBreak('LONG BREAK', 900, 'Long Break');

  final String label;
  final int totalSeconds;
  final String title;

  const FocusMode(this.label, this.totalSeconds, this.title);
}

enum AmbientSound {
  none('None', Icons.volume_off),
  whiteNoise('White Noise', Icons.waves),
  rain('Gentle Rain', Icons.water_drop),
  cafe('Quiet Cafe', Icons.local_cafe);

  final String label;
  final IconData icon;

  const AmbientSound(this.label, this.icon);
}

class AppState extends ChangeNotifier {
  bool _isLoggedIn = true;
  bool get isLoggedIn => _isLoggedIn;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void login(String email, String password) {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // User Profile
  final UserProfile _user = UserProfile(
    name: 'Alex Rivera',
    email: 'alex.rivera@university.edu',
    institution: 'State University • Tech Dept',
    defaultCategory: TaskCategory.school,
    dailyFocusTarget: 4,
    completedTasksCount: 18,
    onTimePercentage: 85,
    focusHours: 14.5,
    streakDays: 4,
  );

  UserProfile get user => _user;

  void updateUser({
    String? name,
    String? email,
    String? institution,
    TaskCategory? defaultCategory,
    int? dailyFocusTarget,
    bool? pushNotificationsEnabled,
  }) {
    if (name != null) _user.name = name;
    if (email != null) _user.email = email;
    if (institution != null) _user.institution = institution;
    if (defaultCategory != null) _user.defaultCategory = defaultCategory;
    if (dailyFocusTarget != null) _user.dailyFocusTarget = dailyFocusTarget;
    if (pushNotificationsEnabled != null) {
      _user.pushNotificationsEnabled = pushNotificationsEnabled;
    }
    notifyListeners();
  }

  // Tasks List
  final List<TaskItem> _tasks = [
    TaskItem(
      id: 'task-1',
      title: 'Review Capstone Project Proposal',
      description: 'Verify 20 sections including objectives, methodology, and architecture.',
      category: TaskCategory.school,
      priority: TaskPriority.high,
      dueDate: DateTime(2026, 11, 7, 16, 15),
      dueTimeString: '4:15 PM',
      isCompleted: true,
      estimatedTime: '45m',
      attachments: [
        TaskAttachment(name: 'proposal_draft.pdf', size: '2.4 MB', type: 'pdf'),
      ],
      subtasks: [
        Subtask(id: 'st-1', title: 'Check literature citations', isCompleted: true),
        Subtask(id: 'st-2', title: 'Verify system requirement matrix', isCompleted: true),
      ],
      activities: [
        TaskActivity(
          title: 'Marked Completed',
          timestamp: 'Nov 7, 2026 · 4:15 PM',
          description: 'Verified with adviser committee',
          icon: Icons.check_circle,
        ),
      ],
    ),
    TaskItem(
      id: 'task-2',
      title: 'Configure Cloud Firestore Database',
      description: 'Setup Firestore collections for users and task documents with security rules and role-based access validation.',
      category: TaskCategory.school,
      priority: TaskPriority.high,
      dueDate: DateTime(2026, 11, 8, 23, 59),
      dueTimeString: '11:59 PM',
      isCompleted: false,
      estimatedTime: '2h',
      attachments: [
        TaskAttachment(name: 'schema_v2.json', size: '142 KB', type: 'json'),
        TaskAttachment(name: 'architecture_diagram.png', size: '1.2 MB', type: 'image'),
      ],
      subtasks: [
        Subtask(id: 'st-1', title: 'Draft Firestore security rules for users collection', isCompleted: true),
        Subtask(id: 'st-2', title: 'Test rules in local emulator suite', isCompleted: false),
        Subtask(id: 'st-3', title: 'Deploy to production & sync schema models', isCompleted: false),
        Subtask(id: 'st-4', title: 'Review validation benchmarks', isCompleted: false),
      ],
      activities: [
        TaskActivity(
          title: 'Updated security rules',
          timestamp: 'Yesterday, 4:12 PM',
          description: 'Added strict write validations on user profile collection.',
          icon: Icons.edit_note,
        ),
        TaskActivity(
          title: 'Task created',
          timestamp: 'Nov 1, 2026',
          description: 'Created by Alex Rivera • Assigned to Cloud Sprint',
          icon: Icons.add_task,
        ),
      ],
    ),
    TaskItem(
      id: 'task-3',
      title: 'Prepare Midterm Documentation',
      description: 'Compile Chapter 1, 2, and 3 manuscripts for adviser review.',
      category: TaskCategory.school,
      priority: TaskPriority.medium,
      dueDate: DateTime(2026, 11, 10, 17, 0),
      dueTimeString: '5:00 PM',
      isCompleted: false,
      estimatedTime: '1h',
      attachments: [
        TaskAttachment(name: 'wireframes.png', size: '1.8 MB', type: 'image'),
      ],
      subtasks: [
        Subtask(id: 'st-1', title: 'Export diagrams to high-res PNG', isCompleted: false),
        Subtask(id: 'st-2', title: 'Format references APA 7th style', isCompleted: false),
      ],
      activities: [
        TaskActivity(
          title: 'Draft initiated',
          timestamp: 'Nov 3, 2026',
          description: 'Outlined Chapter 2 literature survey.',
          icon: Icons.edit,
        ),
      ],
    ),
    TaskItem(
      id: 'task-4',
      title: 'Weekly Team Standup Meeting',
      description: 'Discuss sprint progress and assign development backlog items.',
      category: TaskCategory.work,
      priority: TaskPriority.low,
      dueDate: DateTime(2026, 11, 11, 10, 0),
      dueTimeString: '10:00 AM',
      isCompleted: false,
      estimatedTime: '30m',
      attachments: [],
      subtasks: [
        Subtask(id: 'st-1', title: 'Summarize week commit stats', isCompleted: false),
      ],
      activities: [
        TaskActivity(
          title: 'Scheduled recurring sync',
          timestamp: 'Nov 1, 2026',
          description: 'Calendar sync via Google Meet',
          icon: Icons.event,
        ),
      ],
    ),
  ];

  List<TaskItem> get tasks => List.unmodifiable(_tasks);

  int get totalTasksCount => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingTasksCount => _tasks.where((t) => !t.isCompleted).length;
  double get completionPercentage =>
      totalTasksCount > 0 ? (completedTasksCount / totalTasksCount) * 100 : 0;

  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void addTask(TaskItem task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  // Dashboard Filters
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  TaskCategory _selectedCategoryFilter = TaskCategory.all;
  TaskCategory get selectedCategoryFilter => _selectedCategoryFilter;

  String _selectedStatusTab = 'all'; // 'all' or 'pending'
  String get selectedStatusTab => _selectedStatusTab;

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setStatusTab(String tab) {
    _selectedStatusTab = tab;
    notifyListeners();
  }

  List<TaskItem> get filteredTasks {
    return _tasks.where((task) {
      // Category filter
      if (_selectedCategoryFilter != TaskCategory.all &&
          task.category != _selectedCategoryFilter) {
        return false;
      }

      // Status tab
      if (_selectedStatusTab == 'pending' && task.isCompleted) {
        return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final matchesTitle = task.title.toLowerCase().contains(_searchQuery);
        final matchesDesc =
            task.description.toLowerCase().contains(_searchQuery);
        final matchesCategory =
            task.category.label.toLowerCase().contains(_searchQuery);
        if (!matchesTitle && !matchesDesc && !matchesCategory) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Schedule State
  DateTime _selectedDate = DateTime(2026, 11, 8);
  DateTime get selectedDate => _selectedDate;

  String _scheduleFilter = 'all'; // 'all', 'upcoming', 'completed'
  String get scheduleFilter => _scheduleFilter;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setScheduleFilter(String filter) {
    _scheduleFilter = filter;
    notifyListeners();
  }

  List<TaskItem> get scheduleFilteredTasks {
    return _tasks.where((task) {
      final isSameDay = task.dueDate.year == _selectedDate.year &&
          task.dueDate.month == _selectedDate.month &&
          task.dueDate.day == _selectedDate.day;

      if (!isSameDay) return false;

      if (_scheduleFilter == 'upcoming' && task.isCompleted) return false;
      if (_scheduleFilter == 'completed' && !task.isCompleted) return false;

      return true;
    }).toList();
  }

  // Focus Timer State
  FocusMode _focusMode = FocusMode.pomodoro;
  FocusMode get focusMode => _focusMode;

  late int _remainingSeconds;
  int get remainingSeconds => _remainingSeconds;

  bool _isTimerRunning = false;
  bool get isTimerRunning => _isTimerRunning;

  Timer? _timer;

  String _selectedFocusTaskId = 'task-2';
  String get selectedFocusTaskId => _selectedFocusTaskId;

  TaskItem get selectedFocusTask {
    return _tasks.firstWhere(
      (t) => t.id == _selectedFocusTaskId,
      orElse: () => _tasks.first,
    );
  }

  int _sessionNumber = 2;
  int get sessionNumber => _sessionNumber;

  AmbientSound _ambientSound = AmbientSound.none;
  AmbientSound get ambientSound => _ambientSound;

  AppState() {
    _remainingSeconds = _focusMode.totalSeconds;
  }

  void setFocusTask(String taskId) {
    _selectedFocusTaskId = taskId;
    notifyListeners();
  }

  void setFocusMode(FocusMode mode) {
    pauseTimer();
    _focusMode = mode;
    _remainingSeconds = mode.totalSeconds;
    notifyListeners();
  }

  void setAmbientSound(AmbientSound sound) {
    if (_ambientSound == sound) {
      _ambientSound = AmbientSound.none;
    } else {
      _ambientSound = sound;
    }
    notifyListeners();
  }

  void toggleTimer() {
    if (_isTimerRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (_isTimerRunning) return;
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        pauseTimer();
        advanceSession();
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    _isTimerRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void resetTimer() {
    pauseTimer();
    _remainingSeconds = _focusMode.totalSeconds;
    notifyListeners();
  }

  void advanceSession() {
    _sessionNumber = (_sessionNumber % 4) + 1;
    resetTimer();
    notifyListeners();
  }

  void completeSession() {
    pauseTimer();
    _sessionNumber = (_sessionNumber % 4) + 1;
    resetTimer();
    notifyListeners();
  }

  void toggleSubtask(String taskId, String subtaskId) {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final stIndex =
          _tasks[taskIndex].subtasks.indexWhere((s) => s.id == subtaskId);
      if (stIndex != -1) {
        _tasks[taskIndex].subtasks[stIndex].isCompleted =
            !_tasks[taskIndex].subtasks[stIndex].isCompleted;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.notifier!;
  }
}
