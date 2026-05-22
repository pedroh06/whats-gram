import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.username});

  final String username;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _supabase = Supabase.instance.client;
  final _controller = TextEditingController();

  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true);
  }

  Future<void> _addTask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    _controller.clear();

    await _supabase.from('tasks').insert({
      'username': widget.username,
      'title': title,
    });
  }

  Future<void> _toggleTask(int id, bool current) async {
    await _supabase
        .from('tasks')
        .update({'is_done': !current}).eq('id', id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Colaborativa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nova tarefa...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addTask(),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _addTask,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data!;

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma tarefa ainda.\nAdicione a primeira!'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    final task = tasks[i];
                    final isDone = task['is_done'] as bool;

                    return ListTile(
                      leading: Checkbox(
                        value: isDone,
                        onChanged: (_) =>
                            _toggleTask(task['id'] as int, isDone),
                      ),
                      title: Text(
                        task['title'] as String,
                        style: TextStyle(
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isDone ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Text(
                        'por ${task['username']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => _toggleTask(task['id'] as int, isDone),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
