import 'package:flutter/material.dart';

// Entry point of the app
void main() {
  runApp(const MyApp());
}

// Root widget — sets up the app theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Todo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF), // purple accent
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const TodoScreen(),
    );
  }
}

// A simple model to represent one todo item
class TodoItem {
  String title;
  bool isDone;

  TodoItem({required this.title, this.isDone = false});
}

// Main screen — StatefulWidget because the list changes
class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // The list of todos
  final List<TodoItem> _todos = [];

  // Controls the text input
  final TextEditingController _controller = TextEditingController();

  // Adds a new todo if the text is not empty
  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.add(TodoItem(title: text));
    });

    _controller.clear(); // Clear the input after adding
  }

  // Toggles a todo between done and not done
  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
  }

  // Deletes a todo from the list
  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = _todos.where((t) => t.isDone).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F3FF),

      // ── App Bar ──────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '📝 My Todos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          // Shows how many tasks are done
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$completed / ${_todos.length} done',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────
      body: Column(
        children: [
          // Progress bar (shows completion)
          if (_todos.isNotEmpty)
            LinearProgressIndicator(
              value: _todos.isEmpty ? 0 : completed / _todos.length,
              backgroundColor: Colors.white,
              color: const Color(0xFF6C63FF),
              minHeight: 5,
            ),

          // The list of todos
          Expanded(
            child: _todos.isEmpty
                ? _buildEmptyState() // Show a friendly message if empty
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      return _buildTodoCard(_todos[index], index);
                    },
                  ),
          ),

          // Input area at the bottom
          _buildInputArea(theme),
        ],
      ),
    );
  }

  // ── Empty State Widget ────────────────────────────────────────
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉', style: TextStyle(fontSize: 60)),
          SizedBox(height: 12),
          Text(
            'No todos yet!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 6),
          Text(
            'Add something below to get started.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── Single Todo Card ──────────────────────────────────────────
  Widget _buildTodoCard(TodoItem todo, int index) {
    return Dismissible(
      // Swipe left to delete
      key: Key('$index-${todo.title}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteTodo(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          // Checkbox to mark done
          leading: Checkbox(
            value: todo.isDone,
            activeColor: const Color(0xFF6C63FF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (_) => _toggleTodo(index),
          ),
          // Todo title — strikethrough when done
          title: Text(
            todo.title,
            style: TextStyle(
              fontSize: 16,
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
              color: todo.isDone ? Colors.grey : Colors.black87,
            ),
          ),
          // Delete button
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () => _deleteTodo(index),
          ),
        ),
      ),
    );
  }

  // ── Input Area at the Bottom ──────────────────────────────────
  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _addTodo(), // Add on keyboard "Enter"
              decoration: InputDecoration(
                hintText: 'What do you need to do?',
                filled: true,
                fillColor: const Color(0xFFF4F3FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Add button
          ElevatedButton(
            onPressed: _addTodo,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
