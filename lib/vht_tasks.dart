import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config.dart';
import 'theme.dart';

class VHTTasksPage extends StatefulWidget {
  const VHTTasksPage({super.key});

  @override
  State<VHTTasksPage> createState() => _VHTTasksPageState();
}

class _VHTTasksPageState extends State<VHTTasksPage> {
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _pendingTasks = [];
  List<Map<String, dynamic>> _completedTasks = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFollowups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowups() async {
    setState(() => _isLoading = true);
    try {
      if (usePhpApi) {
        final list = await ApiService.instance.getFollowups();
        setState(() {
          _tasks = list;
          _categorizeTasks();
          _isLoading = false;
        });
      } else {
        // If Firestore is enabled, keep previous behavior. For now,
        // Firestore integration is handled elsewhere.
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showError('Error loading tasks: $e');
      setState(() => _isLoading = false);
    }
  }

  void _categorizeTasks() {
    _pendingTasks = _tasks.where((t) => t['status'].toString().toLowerCase() == 'pending').toList();
    _completedTasks = _tasks.where((t) => t['status'].toString().toLowerCase() == 'completed').toList();
  }

  List<Map<String, dynamic>> get _filteredTasks {
    final tasks = _selectedTabIndex == 0 ? _pendingTasks : _completedTasks;
    if (_searchQuery.isEmpty) return tasks;
    final query = _searchQuery.toLowerCase();
    return tasks.where((t) {
      final title = (t['title'] ?? '').toString().toLowerCase();
      final description = (t['description'] ?? '').toString().toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  Future<void> _markTaskComplete(Map<String, dynamic> task) async {
    try {
      // Optional: API call to update status on server
      setState(() {
        task['status'] = 'Completed';
        task['completedAt'] = DateTime.now().toIso8601String();
        _categorizeTasks();
      });
      _showSuccess('Task marked as complete');
    } catch (e) {
      _showError('Failed to update task');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showTaskDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task['title'] ?? 'Task Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Description:', task['description'] ?? 'N/A'),
              _detailRow('Priority:', task['priority'] ?? 'N/A'),
              _detailRow('Status:', task['status'] ?? 'N/A'),
              _detailRow('Due Date:', task['dueDate'] ?? 'N/A'),
              _detailRow('Assigned By:', task['assignedBy'] ?? 'N/A'),
              _detailRow('Created:', task['createdAt'] ?? 'N/A'),
              if (task['completedAt'] != null)
                _detailRow('Completed:', task['completedAt']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (task['status'].toString().toLowerCase() == 'pending')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _markTaskComplete(task);
              },
              child: const Text('Mark Complete'),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // theme not required here; removed to avoid unused variable warning

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFollowups,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(kLargePadding),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: kDefaultPadding),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Pending Tasks',
                    _pendingTasks.length.toString(),
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: kSmallPadding),
                Expanded(
                  child: _statCard(
                    'Completed',
                    _completedTasks.length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            Row(
              children: [
                Expanded(
                  child: _tabButton('Pending', 0, Colors.orange),
                ),
                const SizedBox(width: kSmallPadding),
                Expanded(
                  child: _tabButton('Completed', 1, Colors.green),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredTasks.isEmpty
                  ? Center(
                child: Text(
                  _selectedTabIndex == 0
                      ? 'No pending tasks'
                      : 'No completed tasks',
                ),
              )
                  : ListView.builder(
                itemCount: _filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = _filteredTasks[index];
                  return _buildTaskCard(task);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(kSmallPadding),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index, Color color) {
    final isSelected = _selectedTabIndex == index;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultRadius),
        ),
      ),
      onPressed: () => setState(() => _selectedTabIndex = index),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final priorityColor = _getPriorityColor(task['priority'] ?? '');
    final isPending = task['status'].toString().toLowerCase() == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      child: InkWell(
        onTap: () => _showTaskDetails(task),
        borderRadius: BorderRadius.circular(kDefaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task['title'] ?? 'Untitled Task',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: priorityColor),
                    ),
                    child: Text(
                      task['priority'] ?? 'Low',
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task['description'] ?? 'No description',
                style: const TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${task['dueDate'] ?? 'No date'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      task['assignedBy'] ?? 'Unknown',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (isPending)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _markTaskComplete(task),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
