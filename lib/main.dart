import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo_app/core/constants/app_config.dart';
import 'package:flutter_todo_app/core/theme/app_theme.dart';
import 'package:flutter_todo_app/data/services/auth_service.dart';
import 'package:flutter_todo_app/data/services/task_service.dart';
import 'package:flutter_todo_app/providers/auth_provider.dart';
import 'package:flutter_todo_app/providers/task_provider.dart';
import 'package:flutter_todo_app/presentation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TodoFlowApp());
}

class TodoFlowApp extends StatelessWidget {
  const TodoFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<TaskService>(create: (_) => TaskService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(ctx.read<AuthService>()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (ctx) => TaskProvider(
            ctx.read<TaskService>(),
            ctx.read<AuthProvider>(),
          ),
          update: (ctx, auth, previous) =>
              previous ?? TaskProvider(ctx.read<TaskService>(), auth),
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppRouter(),
      ),
    );
  }
}