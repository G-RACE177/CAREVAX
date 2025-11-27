import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/appointments_db.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<Map<String, dynamic>> _reminders = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final rows = await AppointmentsDB.instance.readAll();
    setState(() {
      _reminders = rows.where((r) => (r['status'] ?? '').toString().toLowerCase() == 'reminder').map<Map<String,dynamic>>((r) => Map<String,dynamic>.from(r)).toList();
      _reminders.sort((a,b) {
        final da = DateTime.tryParse((a['date'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = DateTime.tryParse((b['date'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return da.compareTo(db);
      });
    });
  }

  Future<void> _showAddReminder() async {
    _titleController.clear();
    _noteController.clear();
    _dateController.clear();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 8),
              TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Note')),
              const SizedBox(height: 8),
              TextField(controller: _dateController, decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final newReminder = {
                    'title': _titleController.text,
                    'notes': _noteController.text,
                    'date': _dateController.text,
                    'status': 'reminder',
                  };
                  await AppointmentsDB.instance.create(newReminder);
                  Navigator.of(ctx).pop();
                  await _loadReminders();
                },
                child: const Text('Add Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders'), backgroundColor: kSecondaryColor),
      body: RefreshIndicator(
        onRefresh: _loadReminders,
        child: _reminders.isEmpty
            ? ListView(padding: const EdgeInsets.all(kDefaultPadding), children: [const SizedBox(height: 80), Center(child: Text('No reminders available', style: TextStyle(color: kTextSecondary)))])
            : ListView.separated(
                padding: const EdgeInsets.all(kDefaultPadding),
                itemCount: _reminders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final r = _reminders[i];
                  return ListTile(
                    leading: Icon(Icons.notifications_active, color: kSecondaryColor),
                    title: Text(r['title'] ?? 'Reminder'),
                    subtitle: Text('${r['date'] ?? ''}\n${r['notes'] ?? ''}'),
                    isThreeLine: true,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminder,
        child: const Icon(Icons.add),
      ),
    );
  }
}
