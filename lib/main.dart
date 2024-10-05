import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

void main() => runApp(TaskManagerApp());

// Task model with name, completion status, priority, and timestamp
class Task {
  String name;
  bool isCompleted;
  String priority;
  DateTime? completedAt; // Completion timestamp

  Task({required this.name, this.isCompleted = false, required this.priority});
}

// Main app for task management
class TaskManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskListScreen(),
    );
  }
}

// Main screen widget for managing tasks
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> tasks = []; // List to store tasks
  final TextEditingController _taskController = TextEditingController(); // Text input controller
  String _selectedPriority = 'Low'; // Default priority

  // Method to add a task to the list
  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        tasks.add(Task(name: _taskController.text, priority: _selectedPriority));
        _taskController.clear(); // Clear the text input field after adding
        _sortTasksByPriority();  // Sort tasks after adding
      });
    }
  }

  // Method to remove a task from the list
  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // Method to toggle the completion status of a task
  void _toggleCompletion(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      tasks[index].completedAt =
          tasks[index].isCompleted ? DateTime.now() : null;
    });
  }

  // Sort tasks based on priority (High > Medium > Low)
  void _sortTasksByPriority() {
    setState(() {
      tasks.sort((a, b) {
        const priorityOrder = {'High': 3, 'Medium': 2, 'Low': 1};
        return priorityOrder[b.priority]! - priorityOrder[a.priority]!;
      });
    });
  }

  // Method to format the date for completed tasks
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat.yMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Manager')),
      backgroundColor: Colors.grey[200], // Set the background color here
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Section for adding tasks
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  // Text input field for task name
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: InputDecoration(
                        labelText: 'Enter task',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // Dropdown for selecting task priority
                  DropdownButton<String>(
                    value: _selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                    items: ['Low', 'Medium', 'High']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Section for showing tasks
            Expanded(
              child: tasks.isNotEmpty
                  ? ListView(
                      children: [
                        // Display ongoing tasks
                        if (tasks.any((task) => !task.isCompleted))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ongoing Tasks',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.indigo),
                              ),
                              ...tasks
                                  .where((task) => !task.isCompleted)
                                  .map((task) => Card(
                                        child: ListTile(
                                          leading: Checkbox(
                                            value: task.isCompleted,
                                            onChanged: (value) =>
                                                _toggleCompletion(
                                                    tasks.indexOf(task)),
                                          ),
                                          title: Text(
                                            task.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          subtitle: Text(
                                              'Priority: ${task.priority}'),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () => _removeTask(
                                                tasks.indexOf(task)),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),

                        SizedBox(height: 20),

                        // Display completed tasks
                        if (tasks.any((task) => task.isCompleted))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Completed Tasks',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.green),
                              ),
                              ...tasks
                                  .where((task) => task.isCompleted)
                                  .map((task) => Card(
                                        color: Colors.green[50],
                                        child: ListTile(
                                          leading: Icon(Icons.check_circle,
                                              color: Colors.green),
                                          title: Text(
                                            task.name,
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          subtitle: Text(
                                              'Completed on: ${_formatDate(task.completedAt)}'),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () => _removeTask(
                                                tasks.indexOf(task)),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                      ],
                    )
                  : Center(child: Text('No tasks added yet.')),
            ),
          ],
        ),
      ),
      // Floating action button to add task
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
