import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/notifications.dart';
import 'package:uuid/uuid.dart';

class TodoProvider extends ChangeNotifier {
  final List<Todo> _todos = [];
  String _searchQuery = '';
  final NotificationService _notificationService = NotificationService();

  List<Todo> get todos => _todos;
  String get searchQuery => _searchQuery;

  List<Todo> get allTodos => _todos.where((todo) => !todo.isCompleted).toList();

  List<Todo> get todayTodos {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _todos.where((todo) => 
      !todo.isCompleted && 
      todo.dateTime.isAfter(today.subtract(const Duration(days: 1))) && 
      todo.dateTime.isBefore(tomorrow)
    ).toList();
  }

  List<Todo> get upcomingTodos {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _todos.where((todo) => 
      !todo.isCompleted && 
      todo.dateTime.isAfter(tomorrow.subtract(const Duration(seconds: 1)))
    ).toList();
  }

  List<Todo> get completedTodos => _todos.where((todo) => todo.isCompleted).toList();

  List<Todo> get searchResults {
    if (_searchQuery.isEmpty) {
      return [];
    }
    return _todos
        .where((todo) => 
            !todo.isCompleted &&
            todo.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> addTodo(String title, String? description, DateTime dateTime) async {
    final id = const Uuid().v4();
    final newTodo = Todo(
      id: id,
      title: title,
      description: description,
      dateTime: dateTime,
    );
    _todos.add(newTodo);
    
    await _scheduleNotification(newTodo);
    notifyListeners();
  }

  Future<void> toggleTodoStatus(String id) async {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex >= 0) {
      _todos[todoIndex] = _todos[todoIndex].copyWith(
        isCompleted: !_todos[todoIndex].isCompleted,
      );

      if (_todos[todoIndex].isCompleted) {
        await _notificationService.cancelNotification(id);
      } else {
        if (_todos[todoIndex].dateTime.isAfter(DateTime.now())) {
          await _scheduleNotification(_todos[todoIndex]);
        }
      }
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    await _notificationService.cancelNotification(id);
    
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  Future<void> _scheduleNotification(Todo todo) async {
    if (!todo.isCompleted && todo.dateTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: todo.id,
        title: 'Upcoming Task: ${todo.title}',
        body: 'Your task is due in 10 minutes',
        scheduledTime: todo.dateTime,
      );
    }
  }

  Future<void> rescheduleAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    for (var todo in _todos) {
      if (!todo.isCompleted && todo.dateTime.isAfter(DateTime.now())) {
        await _scheduleNotification(todo);
      }
    }
  }
}

