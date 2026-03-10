import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo_app/core/theme/app_theme.dart';
import 'package:flutter_todo_app/core/utils/app_utils.dart';
import 'package:flutter_todo_app/providers/auth_provider.dart';
import 'package:flutter_todo_app/providers/task_provider.dart';
import 'package:flutter_todo_app/presentation/home/widgets/add_task_sheet.dart';
import 'package:flutter_todo_app/presentation/home/widgets/empty_state.dart';
import 'package:flutter_todo_app/presentation/home/widgets/filter_tab_bar.dart';
import 'package:flutter_todo_app/presentation/home/widgets/task_stats_header.dart';
import 'package:flutter_todo_app/presentation/home/widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<TaskProvider>().reset();
      context.read<AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('TodoFlow'),
          ],
        ),
        actions: [
          if (!AppUtils.isMobile(context))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  auth.userEmail ?? '',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: tasks.isLoading ? null : () => tasks.fetchTasks(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: AppUtils.contentMaxWidth(context)),
          child: RefreshIndicator(
            onRefresh: tasks.fetchTasks,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: TaskStatsHeader(taskProvider: tasks),
                ),
                const SliverToBoxAdapter(child: FilterTabBar()),
                if (tasks.errorMessage != null)
                  SliverToBoxAdapter(
                    child: _ErrorBanner(
                      message: tasks.errorMessage!,
                      onDismiss: tasks.clearError,
                    ),
                  ),
                if (tasks.isLoading && tasks.tasks.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primaryColor),
                    ),
                  )
                else if (tasks.tasks.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(filter: tasks.filter),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TaskTile(task: tasks.tasks[i]),
                        childCount: tasks.tasks.length,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddTaskSheet.show(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        heroTag: 'add_task_fab',
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppTheme.errorColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppTheme.errorColor, fontSize: 13)),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close,
                color: AppTheme.errorColor, size: 18),
          ),
        ],
      ),
    );
  }
}