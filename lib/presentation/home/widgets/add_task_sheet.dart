import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_todo_app/core/constants/app_config.dart';
import 'package:flutter_todo_app/core/theme/app_theme.dart';
import 'package:flutter_todo_app/core/utils/app_utils.dart';
import 'package:flutter_todo_app/providers/task_provider.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _ctrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _loading = true);
    final provider = context.read<TaskProvider>();
    final success = await provider.addTask(title);

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context);
      AppUtils.showSnackBar(context, 'Task added!');
    } else {
      AppUtils.showSnackBar(
        context,
        provider.errorMessage ?? 'Failed to add task.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'New Task',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            maxLines: 3,
            minLines: 1,
            maxLength: AppConfig.taskTitleMaxLength,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _add(),
            decoration: const InputDecoration(
              hintText: 'What do you need to do?',
              prefixIcon: Icon(Icons.add_task),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loading ? null : _add,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check, size: 20),
            label: Text(_loading ? 'Adding...' : 'Add Task'),
          ),
        ],
      ),
    );
  }
}