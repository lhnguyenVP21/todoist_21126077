import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';
import 'package:intl/intl.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final String emptyMessage;
  final bool isCompletedList;

  const TodoList({
    super.key,
    required this.todos,
    required this.emptyMessage,
    this.isCompletedList = false,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Group todos by date
    final Map<String, List<Todo>> groupedTodos = {};
    
    for (var todo in todos) {
      final date = DateFormat('d MMM').format(todo.dateTime);
      final day = DateFormat('EEEE').format(todo.dateTime);
      final key = '$date • $day';
      
      if (!groupedTodos.containsKey(key)) {
        groupedTodos[key] = [];
      }
      groupedTodos[key]!.add(todo);
    }

    // Sort the keys by date
    final sortedKeys = groupedTodos.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('d MMM').parse(a.split(' • ')[0]);
        final dateB = DateFormat('d MMM').parse(b.split(' • ')[0]);
        return dateA.compareTo(dateB);
      });

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final todosForDate = groupedTodos[dateKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ...todosForDate.map((todo) => TodoItem(
              todo: todo,
              isCompletedList: isCompletedList,
            )).toList(),
            if (index < sortedKeys.length - 1)
              const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

