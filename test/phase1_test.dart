// ignore_for_file: avoid_print
import 'package:flutter_application_1/models/task_model.dart';
import 'package:flutter_application_1/state/app_state.dart';

int _passCount = 0;
int _failCount = 0;

void expect(dynamic actual, dynamic expected, String scenario) {
  if (actual == expected) {
    _passCount++;
    print('  [PASS] $scenario');
  } else {
    _failCount++;
    print('  [FAIL] $scenario (Expected: $expected, Actual: $actual)');
  }
}

void expectTrue(bool condition, String scenario) {
  if (condition) {
    _passCount++;
    print('  [PASS] $scenario');
  } else {
    _failCount++;
    print('  [FAIL] $scenario (Expected true, got false)');
  }
}

void expectFalse(bool condition, String scenario) {
  if (!condition) {
    _passCount++;
    print('  [PASS] $scenario');
  } else {
    _failCount++;
    print('  [FAIL] $scenario (Expected false, got true)');
  }
}

void main() async {
  print('====================================================');
  print(' TASKMATE PHASE 1 TEST SUITE');
  print('====================================================\n');

  // --- Group 1: Model Tests ---
  print('GROUP 1: Model and Data Structure Tests');
  final task = TaskItem(
    id: 'test-1',
    title: 'Complete Math Assignment',
    description: 'Differential equations',
    category: TaskCategory.school,
    priority: TaskPriority.high,
    dueDate: DateTime(2026, 11, 10),
    dueTimeString: '10:00 AM',
    subtasks: [
      Subtask(id: 's1', title: 'Part 1', isCompleted: true),
      Subtask(id: 's2', title: 'Part 2', isCompleted: false),
    ],
  );

  expect(task.subtasksCompletionRatio, 0.5, 'TaskItem calculates 50% subtask ratio');

  final modified = task.copyWith(
    title: 'Updated Title',
    priority: TaskPriority.low,
  );
  expect(task.title, 'Complete Math Assignment', 'Original task immutable on copyWith');
  expect(modified.title, 'Updated Title', 'Modified clone updated title');
  expect(modified.priority, TaskPriority.low, 'Modified clone updated priority');

  final notif = NotificationItem(
    id: 'n-1',
    title: 'Due Alert',
    message: 'Task is due in 1 hour',
    timestamp: 'Just now',
    dateTime: DateTime.now(),
    taskId: 'test-1',
    type: 'reminder',
  );
  expectFalse(notif.isRead, 'NotificationItem initial isRead status is false');
  expect(notif.taskId, 'test-1', 'NotificationItem retains target taskId');

  // --- Group 2: AppState Task CRUD & Lifecycle ---
  print('\nGROUP 2: AppState Task CRUD & Statistics Tests');
  final state = AppState();

  expect(state.totalTasksCount, 4, 'Initial total task count equals 4');
  expect(state.completedTasksCount, 1, 'Initial completed task count equals 1');
  expect(state.pendingTasksCount, 3, 'Initial pending task count equals 3');
  expect(state.completionPercentage, 25.0, 'Initial completion percentage is 25%');

  // Add Task
  final newTask = TaskItem(
    id: 'new-101',
    title: 'Prepare Presentation Slides',
    description: 'Design pitch deck for seminar',
    category: TaskCategory.school,
    priority: TaskPriority.medium,
    dueDate: DateTime(2026, 11, 15),
    dueTimeString: '3:00 PM',
  );
  state.addTask(newTask);
  expect(state.totalTasksCount, 5, 'Adding task increments totalTasksCount to 5');
  expect(state.tasks.first.id, 'new-101', 'New task inserted at head of list');
  expect(state.notifications.first.title, 'New Task Created', 'Adding task generates notification alert');

  // Update Task
  final updatedTask = state.tasks.firstWhere((t) => t.id == 'task-2').copyWith(
    title: 'Configure Cloud Firestore Database (Updated)',
    priority: TaskPriority.medium,
  );
  state.updateTask(updatedTask);
  final retrieved = state.tasks.firstWhere((t) => t.id == 'task-2');
  expect(retrieved.title, 'Configure Cloud Firestore Database (Updated)', 'Task title updated in state');
  expect(retrieved.priority, TaskPriority.medium, 'Task priority updated in state');
  expect(retrieved.activities.first.title, 'Task Edited', 'Audit trail records Task Edited activity');

  // Toggle Task Completion
  expectFalse(state.tasks.firstWhere((t) => t.id == 'task-2').isCompleted, 'Task-2 initially pending');
  state.toggleTaskCompletion('task-2');
  final completedTask = state.tasks.firstWhere((t) => t.id == 'task-2');
  expectTrue(completedTask.isCompleted, 'Task-2 marked as completed');
  expectTrue(completedTask.completedAt != null, 'Task-2 recorded completion timestamp');
  expect(state.completedTasksCount, 2, 'Completed tasks count incremented to 2');
  expect(state.completionPercentage, 40.0, 'Completion percentage recalculated to 40%');
  expect(completedTask.activities.first.title, 'Marked Completed', 'Audit trail logged Marked Completed');

  // Reopen Task
  state.toggleTaskCompletion('task-2');
  final reopenedTask = state.tasks.firstWhere((t) => t.id == 'task-2');
  expectFalse(reopenedTask.isCompleted, 'Task-2 reopened to pending');
  expectTrue(reopenedTask.completedAt == null, 'Reopened task cleared completion timestamp');

  // Subtask Toggling
  state.toggleSubtask('task-2', 'st-2');
  expectTrue(state.tasks.firstWhere((t) => t.id == 'task-2').subtasks.firstWhere((s) => s.id == 'st-2').isCompleted, 'Subtask st-2 toggled to completed');
  state.toggleSubtask('task-2', 'st-2');
  expectFalse(state.tasks.firstWhere((t) => t.id == 'task-2').subtasks.firstWhere((s) => s.id == 'st-2').isCompleted, 'Subtask st-2 toggled back to pending');

  // Delete Task
  state.deleteTask('task-4');
  expectFalse(state.tasks.any((t) => t.id == 'task-4'), 'Task-4 removed from tasks list');
  expectFalse(state.notifications.any((n) => n.taskId == 'task-4'), 'Associated notifications removed on task delete');

  // --- Group 3: Search, Filter, and Status Tabs ---
  print('\nGROUP 3: Search, Filter, and Status Tabs Tests');
  state.setSearchQuery('firestore');
  final searchResults = state.filteredTasks;
  expect(searchResults.length, 1, 'Search query "firestore" returns 1 matching task');
  expect(searchResults.first.id, 'task-2', 'Search query returned matching task-2');
  state.setSearchQuery('');

  state.setCategoryFilter(TaskCategory.school);
  final schoolTasks = state.filteredTasks;
  expectTrue(schoolTasks.every((t) => t.category == TaskCategory.school), 'Category filter isolates only School tasks');

  state.setCategoryFilter(TaskCategory.all);
  state.setStatusTab('pending');
  final pendingTasks = state.filteredTasks;
  expectTrue(pendingTasks.every((t) => !t.isCompleted), 'Pending status tab isolates incomplete tasks');
  state.setStatusTab('all');

  // --- Group 4: Notifications Management ---
  print('\nGROUP 4: Notifications Management Tests');
  final unreadBefore = state.unreadNotificationsCount;
  expectTrue(unreadBefore > 0, 'Unread notification count is positive');

  final firstNotifId = state.notifications.first.id;
  state.markNotificationAsRead(firstNotifId);
  expect(state.unreadNotificationsCount, unreadBefore - 1, 'Marking notification read decrements unread count');

  state.markAllNotificationsAsRead();
  expect(state.unreadNotificationsCount, 0, 'Marking all read sets unread count to 0');
  expectTrue(state.notifications.every((n) => n.isRead), 'All notifications are marked read');

  final countBeforeDel = state.notifications.length;
  state.deleteNotification(firstNotifId);
  expect(state.notifications.length, countBeforeDel - 1, 'Deleting notification removes it from list');

  // --- Group 5: Authentication & User Profile ---
  print('\nGROUP 5: Authentication & Profile Tests');
  await state.login('student@university.edu', 'password123', name: 'Jordan Lee');
  expectTrue(state.isLoggedIn, 'User logged in status is true');
  expect(state.user.name, 'Jordan Lee', 'Logged-in user name updated');
  expect(state.user.email, 'student@university.edu', 'Logged-in user email updated');

  await state.register('Morgan Reed', 'morgan@inst.edu', 'secure2026!');
  expectTrue(state.isLoggedIn, 'Registered user session active');
  expect(state.user.name, 'Morgan Reed', 'Registered name saved in profile');

  state.updateUser(
    name: 'Morgan Reed Updated',
    institution: 'Technology Institute',
    dailyFocusTarget: 5,
  );
  expect(state.user.name, 'Morgan Reed Updated', 'Profile name updated');
  expect(state.user.institution, 'Technology Institute', 'Profile institution updated');
  expect(state.user.dailyFocusTarget, 5, 'Daily focus target updated to 5');

  await state.logout();
  expectFalse(state.isLoggedIn, 'User logged out status is false');

  // --- Group 6: Focus Timer & Schedule ---
  print('\nGROUP 6: Focus Timer & Schedule Tests');
  state.setFocusTask('task-3');
  expect(state.selectedFocusTaskId, 'task-3', 'Selected focus task id updated');
  expect(state.selectedFocusTask.id, 'task-3', 'Selected focus task object retrieved');

  state.setFocusMode(FocusMode.shortBreak);
  expect(state.focusMode, FocusMode.shortBreak, 'Focus mode switched to shortBreak');
  expect(state.remainingSeconds, 300, 'Remaining seconds set to 300 for shortBreak');

  state.setFocusMode(FocusMode.pomodoro);
  expect(state.remainingSeconds, 1500, 'Remaining seconds set to 1500 for pomodoro');

  state.setSelectedDate(DateTime(2026, 11, 8));
  expect(state.selectedDate.day, 8, 'Schedule selected date set to Nov 8');

  print('\n====================================================');
  print(' TEST RESULTS: $_passCount PASSED, $_failCount FAILED');
  print('====================================================');

  if (_failCount > 0) {
    throw Exception('Phase 1 test suite had $_failCount failures.');
  }
}
