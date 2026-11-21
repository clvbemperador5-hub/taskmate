import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/firebase_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/app_nav_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Connection
  await FirebaseService.instance.initialize();

  runApp(const TaskMateApp());
}

class TaskMateApp extends StatefulWidget {
  const TaskMateApp({super.key});

  @override
  State<TaskMateApp> createState() => _TaskMateAppState();
}

class _TaskMateAppState extends State<TaskMateApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      notifier: _appState,
      child: ListenableBuilder(
        listenable: _appState,
        builder: (context, _) {
          return MaterialApp(
            title: 'TaskMate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: _appState.isLoggedIn
                ? const AppNavShell()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
