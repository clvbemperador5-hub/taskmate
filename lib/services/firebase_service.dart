import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';
import '../models/task_model.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _initialized = true;

      // Enable offline persistence for Firestore
      try {
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (e) {
        debugPrint('Firestore persistence already set or not supported: $e');
      }
    } catch (e) {
      debugPrint('FirebaseService initialize error: $e');
      _initialized = false;
    }
  }

  // -------------------------------------------------------------
  // Authentication
  // -------------------------------------------------------------

  User? get currentUser => _initialized ? auth.currentUser : null;

  Stream<User?> get authStateChanges {
    if (!_initialized) return const Stream.empty();
    return auth.authStateChanges();
  }

  Future<UserCredential> signIn(String email, String password) async {
    if (!_initialized) await initialize();
    return await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> register(
    String name,
    String email,
    String password,
  ) async {
    if (!_initialized) await initialize();
    final cred = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update display name
    await cred.user?.updateDisplayName(name.trim());

    // Create user profile in Firestore
    if (cred.user != null) {
      final initialProfile = UserProfile(
        name: name.trim(),
        email: email.trim(),
        institution: 'University • Student',
        defaultCategory: TaskCategory.school,
        dailyFocusTarget: 4,
        completedTasksCount: 0,
        onTimePercentage: 100,
        focusHours: 0.0,
        streakDays: 1,
      );
      await saveUserProfile(cred.user!.uid, initialProfile);
    }

    return cred;
  }

  Future<void> sendPasswordReset(String email) async {
    if (!_initialized) await initialize();
    await auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    if (!_initialized) return;
    await auth.signOut();
  }

  // -------------------------------------------------------------
  // User Profile in Cloud Firestore (`users/{uid}`)
  // -------------------------------------------------------------

  Future<UserProfile?> fetchUserProfile(String uid) async {
    if (!_initialized) return null;
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;

      return UserProfile(
        name: data['name'] as String? ?? 'User',
        email: data['email'] as String? ?? '',
        institution: data['institution'] as String? ?? 'University',
        defaultCategory: TaskCategory.fromString(
          data['defaultCategory'] as String? ?? 'school',
        ),
        dailyFocusTarget: (data['dailyFocusTarget'] as num?)?.toInt() ?? 4,
        completedTasksCount: (data['completedTasksCount'] as num?)?.toInt() ?? 0,
        onTimePercentage: (data['onTimePercentage'] as num?)?.toInt() ?? 100,
        focusHours: (data['focusHours'] as num?)?.toDouble() ?? 0.0,
        streakDays: (data['streakDays'] as num?)?.toInt() ?? 1,
        pushNotificationsEnabled:
            data['pushNotificationsEnabled'] as bool? ?? true,
      );
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> saveUserProfile(String uid, UserProfile profile) async {
    if (!_initialized) return;
    await firestore.collection('users').doc(uid).set({
      'name': profile.name,
      'email': profile.email,
      'institution': profile.institution,
      'defaultCategory': profile.defaultCategory.label,
      'dailyFocusTarget': profile.dailyFocusTarget,
      'completedTasksCount': profile.completedTasksCount,
      'onTimePercentage': profile.onTimePercentage,
      'focusHours': profile.focusHours,
      'streakDays': profile.streakDays,
      'pushNotificationsEnabled': profile.pushNotificationsEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // -------------------------------------------------------------
  // Tasks in Cloud Firestore (`users/{uid}/tasks/{taskId}`)
  // -------------------------------------------------------------

  Stream<List<TaskItem>> streamTasks(String uid) {
    if (!_initialized) return const Stream.empty();
    return firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _taskFromFirestore(doc)).toList();
    });
  }

  Future<void> saveTask(String uid, TaskItem task) async {
    if (!_initialized) return;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .set(_taskToFirestore(task));
  }

  Future<void> updateTask(String uid, TaskItem task) async {
    if (!_initialized) return;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(task.id)
        .set(_taskToFirestore(task), SetOptions(merge: true));
  }

  Future<void> deleteTask(String uid, String taskId) async {
    if (!_initialized) return;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<void> toggleTaskCompletion(
    String uid,
    String taskId,
    bool isCompleted,
  ) async {
    if (!_initialized) return;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .update({
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // -------------------------------------------------------------
  // Storage: File Attachments (`users/{uid}/tasks/{taskId}/{name}`)
  // -------------------------------------------------------------

  Future<String?> uploadAttachment({
    required String uid,
    required String taskId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    if (!_initialized) return null;
    try {
      final ref = storage
          .ref()
          .child('users')
          .child(uid)
          .child('tasks')
          .child(taskId)
          .child(fileName);

      final uploadTask = await ref.putData(fileBytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading attachment to Firebase Storage: $e');
      return null;
    }
  }

  // -------------------------------------------------------------
  // Data Mappers
  // -------------------------------------------------------------

  Map<String, dynamic> _taskToFirestore(TaskItem task) {
    return {
      'title': task.title,
      'description': task.description,
      'category': task.category.label,
      'priority': task.priority.label,
      'dueDate': Timestamp.fromDate(task.dueDate),
      'dueTimeString': task.dueTimeString,
      'isCompleted': task.isCompleted,
      'completedAt': task.completedAt != null
          ? Timestamp.fromDate(task.completedAt!)
          : null,
      'estimatedTime': task.estimatedTime,
      'subtasks': task.subtasks.map((s) => {
        'id': s.id,
        'title': s.title,
        'isCompleted': s.isCompleted,
      }).toList(),
      'attachments': task.attachments.map((a) => {
        'name': a.name,
        'size': a.size,
        'type': a.type,
      }).toList(),
      'activities': task.activities.map((act) => {
        'title': act.title,
        'timestamp': act.timestamp,
        'description': act.description,
      }).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  TaskItem _taskFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    DateTime dueDate = DateTime.now();
    if (data['dueDate'] is Timestamp) {
      dueDate = (data['dueDate'] as Timestamp).toDate();
    }

    DateTime? completedAt;
    if (data['completedAt'] is Timestamp) {
      completedAt = (data['completedAt'] as Timestamp).toDate();
    }

    final subtasksRaw = data['subtasks'] as List<dynamic>? ?? [];
    final subtasks = subtasksRaw.map((s) {
      final map = s as Map<String, dynamic>;
      return Subtask(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        isCompleted: map['isCompleted'] as bool? ?? false,
      );
    }).toList();

    final attachmentsRaw = data['attachments'] as List<dynamic>? ?? [];
    final attachments = attachmentsRaw.map((a) {
      final map = a as Map<String, dynamic>;
      return TaskAttachment(
        name: map['name'] as String? ?? 'file',
        size: map['size'] as String? ?? '1 MB',
        type: map['type'] as String? ?? 'other',
      );
    }).toList();

    final activitiesRaw = data['activities'] as List<dynamic>? ?? [];
    final activities = activitiesRaw.map((act) {
      final map = act as Map<String, dynamic>;
      return TaskActivity(
        title: map['title'] as String? ?? 'Activity',
        timestamp: map['timestamp'] as String? ?? 'Recent',
        description: map['description'] as String? ?? '',
        icon: Icons.history,
      );
    }).toList();

    return TaskItem(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled Task',
      description: data['description'] as String? ?? '',
      category: TaskCategory.fromString(data['category'] as String? ?? 'school'),
      priority: TaskPriority.values.firstWhere(
        (p) => p.label.toLowerCase() == (data['priority'] as String? ?? 'medium').toLowerCase(),
        orElse: () => TaskPriority.medium,
      ),
      dueDate: dueDate,
      dueTimeString: data['dueTimeString'] as String? ?? '12:00 PM',
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: completedAt,
      estimatedTime: data['estimatedTime'] as String? ?? '1h',
      subtasks: subtasks,
      attachments: attachments,
      activities: activities,
    );
  }
}
