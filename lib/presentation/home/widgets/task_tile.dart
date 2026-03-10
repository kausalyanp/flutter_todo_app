import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo_app/core/theme/app_theme.dart';
import 'package:flutter_todo_app/core/utils/app_utils.dart';
import 'package:flutter_todo_app/data/models/task_model.dart';
import 'package:flutter_todo_app/providers/task_provider.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;

  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) async {
        final deleted = await taskProvider.deleteTask(task.id);
        if (!deleted && context.mounted) {
          AppUtils.showSnackBar(context, 'Failed to delete task.',
              isError: true);
        }
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => taskProvider.toggleCompletion(task),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Checkbox(
                  value: task.completed,
                  onChanged: (_) => taskProvider.toggleCompletion(task),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: task.completed
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.createdAt != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          AppUtils.formatDate(task.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (task.completed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                PopupMenuButton<_TaskAction>(
                  icon: const Icon(Icons.more_vert,
                      color: AppTheme.textSecondary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (action) {
                    if (action == _TaskAction.edit) {
                      _showEditDialog(context, task);
                    } else if (action == _TaskAction.delete) {
                      _confirmAndDelete(context, taskProvider);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _TaskAction.edit,
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: _TaskAction.delete,
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child:
          const Icon(Icons.delete_outline, color: Colors.white, size: 26),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Task'),
            content:
                const Text('Are you sure you want to delete this task?'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _confirmAndDelete(
      BuildContext context, TaskProvider taskProvider) async {
    final confirmed = await _confirmDelete(context);
    if (confirmed && context.mounted) {
      final deleted = await taskProvider.deleteTask(task.id);
      if (!deleted && context.mounted) {
        AppUtils.showSnackBar(context, 'Failed to delete task.',
            isError: true);
      }
    }
  }

  void _showEditDialog(BuildContext context, TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => _EditTaskDialog(task: task),
    );
  }
}

enum _TaskAction { edit, delete }

class _EditTaskDialog extends StatefulWidget {
  final TaskModel task;
  const _EditTaskDialog({required this.task});

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late final TextEditingController _ctrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.task.title);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final provider = context.read<TaskProvider>();
    final success =
        await provider.updateTaskTitle(widget.task, _ctrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      Navigator.pop(context);
    } else {
      AppUtils.showSnackBar(
          context, provider.errorMessage ?? 'Update failed.',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        maxLines: 3,
        minLines: 1,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        decoration: const InputDecoration(
          hintText: 'Task title...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}