import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/visits_db.dart';

class ImmunizationHistoryPage extends StatefulWidget {
  const ImmunizationHistoryPage({super.key});

  @override
  State<ImmunizationHistoryPage> createState() => _ImmunizationHistoryPageState();
}

class _ImmunizationHistoryPageState extends State<ImmunizationHistoryPage> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final rows = await VisitsDB.instance.readAll();
    setState(() {
      // assume visits table stores vaccine events; sort by date if available
      _records = List<Map<String, dynamic>>.from(rows);
      _records.sort((a, b) {
        final da = DateTime.tryParse((a['date'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = DateTime.tryParse((b['date'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });
    });
  }

  Widget _recordTile(Map<String, dynamic> r) {
    final date = r['date'] ?? '';
    final vaccine = r['vaccine'] ?? r['notes'] ?? 'Vaccine';
    final status = r['status'] ?? '';
    return ListTile(
      leading: Icon(Icons.medical_information, color: kPrimaryColor),
      title: Text(vaccine.toString()),
      subtitle: Text('$date • ${status.toString()}'),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Immunization History'), backgroundColor: kPrimaryColor),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: _records.isEmpty
            ? ListView(padding: const EdgeInsets.all(kDefaultPadding), children: [const SizedBox(height: 80), Center(child: Text('No immunization records found', style: TextStyle(color: kTextSecondary)))])
            : ListView.separated(
                padding: const EdgeInsets.all(kDefaultPadding),
                itemCount: _records.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) => _recordTile(_records[i]),
              ),
      ),
    );
  }
}
