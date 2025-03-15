import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list.dart';
import 'package:provider/provider.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final completedTodos = todoProvider.completedTodos;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completed',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${completedTodos.length} tasks',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: TodoList(
        todos: completedTodos,
        emptyMessage: 'No completed tasks',
        isCompletedList: true,
      ),
    );
  }
}

