import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TaskPriority {
  high('High', 'Critical', AppColors.highPriorityBorder, AppColors.highPriorityFill, AppColors.highPriorityText),
  medium('Medium', 'Standard', AppColors.mediumPriorityBorder, AppColors.mediumPriorityFill, AppColors.mediumPriorityText),
  low('Low', 'Flexible', AppColors.lowPriorityBorder, AppColors.lowPriorityFill, AppColors.lowPriorityText);

  final String label;
  final String subtitle;
  final Color borderColor;
  final Color fillColor;
  final Color textColor;

  const TaskPriority(this.label, this.subtitle, this.borderColor, this.fillColor, this.textColor);
}

enum TaskCategory {
  all('All', '📁', Icons.apps),
  school('School', '🎓', Icons.school),
  work('Work', '💼', Icons.work),
  personal('Personal', '🌱', Icons.spa),
  health('Health', '⚡', Icons.fitness_center),
  general('General', '📂', Icons.folder);

  final String label;
  final String emoji;
  final IconData icon;

  const TaskCategory(this.label, this.emoji, this.icon);

  static TaskCategory fromString(String val) {
    return TaskCategory.values.firstWhere(
      (c) => c.label.toLowerCase() == val.toLowerCase(),
      orElse: () => TaskCategory.school,
    );
  }
}

class Subtask {
  String id;
  String title;
  bool isCompleted;

  Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class TaskAttachment {
  final String name;
  final String size;
  final String type; // 'pdf', 'image', 'json', 'other'

  TaskAttachment({
    required this.name,
    required this.size,
    required this.type,
  });
}

class TaskActivity {
  final String title;
  final String timestamp;
  final String description;
  final IconData icon;

  TaskActivity({
    required this.title,
    required this.timestamp,
    required this.description,
    required this.icon,
  });
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final DateTime dateTime;
  bool isRead;
  final String? taskId;
  final String type; // 'reminder', 'due_today', 'overdue', 'completed'

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.dateTime,
    this.isRead = false,
    this.taskId,
    this.type = 'reminder',
  });
}

class TaskItem {
  final String id;
  String title;
  String description;
  TaskCategory category;
  TaskPriority priority;
  DateTime dueDate;
  String dueTimeString;
  bool isCompleted;
  DateTime? completedAt;
  bool isSynced;
  String? attachmentPreview;
  List<TaskAttachment> attachments;
  List<Subtask> subtasks;
  List<TaskActivity> activities;
  String estimatedTime;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.dueTimeString,
    this.isCompleted = false,
    this.completedAt,
    this.isSynced = true,
    this.attachmentPreview,
    List<TaskAttachment>? attachments,
    List<Subtask>? subtasks,
    List<TaskActivity>? activities,
    this.estimatedTime = '2h',
  })  : attachments = attachments ?? [],
        subtasks = subtasks ?? [],
        activities = activities ?? [];

  double get subtasksCompletionRatio {
    if (subtasks.isEmpty) return 0.0;
    final done = subtasks.where((s) => s.isCompleted).length;
    return done / subtasks.length;
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    DateTime? dueDate,
    String? dueTimeString,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isSynced,
    String? attachmentPreview,
    List<TaskAttachment>? attachments,
    List<Subtask>? subtasks,
    List<TaskActivity>? activities,
    String? estimatedTime,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTimeString: dueTimeString ?? this.dueTimeString,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isSynced: isSynced ?? this.isSynced,
      attachmentPreview: attachmentPreview ?? this.attachmentPreview,
      attachments: attachments ?? List.from(this.attachments),
      subtasks: subtasks ?? List.from(this.subtasks),
      activities: activities ?? List.from(this.activities),
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }
}

class UserProfile {
  String name;
  String email;
  String institution;
  TaskCategory defaultCategory;
  int dailyFocusTarget; // e.g. 4
  int completedTasksCount;
  int onTimePercentage;
  double focusHours;
  int streakDays;
  bool pushNotificationsEnabled;

  UserProfile({
    required this.name,
    required this.email,
    required this.institution,
    required this.defaultCategory,
    this.dailyFocusTarget = 4,
    this.completedTasksCount = 18,
    this.onTimePercentage = 85,
    this.focusHours = 14.5,
    this.streakDays = 4,
    this.pushNotificationsEnabled = true,
  });
}
