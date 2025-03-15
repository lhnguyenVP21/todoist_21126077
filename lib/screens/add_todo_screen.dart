import 'package:flutter/material.dart';
import '../providers/todo_provider.dart';
import 'package:provider/provider.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    _selectedTime = TimeOfDay.now();
    if (_selectedTime.minute >= 55) {
      _selectedTime = TimeOfDay(hour: (_selectedTime.hour + 1) % 24, minute: 0);
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        picked.hour,
        picked.minute,
      );
      if (_selectedDate.year == now.year &&
          _selectedDate.month == now.month &&
          _selectedDate.day == now.day &&
          selectedDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot select a time in the past'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _selectedTime = picked;
        _selectedDate = selectedDateTime;
      });
    }
  }

  void _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      if (_selectedDate.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot create a task with a past date/time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final todoProvider = Provider.of<TodoProvider>(context, listen: false);
      await todoProvider.addTodo(
        _titleController.text,
        _descriptionController.text.isEmpty ? null : _descriptionController.text,
        _selectedDate,
      );
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTodo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

