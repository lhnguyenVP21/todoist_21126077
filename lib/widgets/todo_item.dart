import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final bool isCompletedList;

  const TodoItem({
    super.key,
    required this.todo,
    this.isCompletedList = false,
  });

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final timeFormat = DateFormat('HH:mm');

    return Dismissible(
      key: Key(todo.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        todoProvider.deleteTodo(todo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${todo.title} deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black12,
              width: 0.5,
            ),
          ),
        ),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            activeColor: Theme.of(context).colorScheme.primary,
            shape: const CircleBorder(),
            onChanged: (bool? value) {
              todoProvider.toggleTodoStatus(todo.id);
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: todo.description != null && todo.description!.isNotEmpty
              ? Text(
                  todo.description!,
                  style: TextStyle(
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    color: Colors.grey,
                  ),
                )
              : Text(
                  timeFormat.format(todo.dateTime),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
          trailing: isCompletedList
              ? null
              : Text(
                  timeFormat.format(todo.dateTime),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
        ),
      ),
    );
  }
}

