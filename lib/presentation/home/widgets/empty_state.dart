import 'package:flutter/material.dart';
import 'package:flutter_todo_app/core/theme/app_theme.dart';
import 'package:flutter_todo_app/providers/task_provider.dart';

class EmptyState extends StatelessWidget {
  final TaskFilter filter;

  const EmptyState({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = _content();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 72,
                color: AppTheme.primaryLight.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }

  (IconData, String, String) _content() {
    switch (filter) {
      case TaskFilter.all:
        return (
          Icons.playlist_add_check_rounded,
          'No tasks yet',
          'Tap the + button to add your first task.',
        );
      case TaskFilter.active:
        return (
          Icons.check_circle_outline,
          'All done!',
          'You have no active tasks. Great work!',
        );
      case TaskFilter.completed:
        return (
          Icons.hourglass_empty_rounded,
          'No completed tasks',
          'Complete a task to see it here.',
        );
    }
  }
}