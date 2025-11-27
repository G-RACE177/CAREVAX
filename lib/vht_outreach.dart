import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme.dart';

class VHTOutreachPage extends StatefulWidget {
  const VHTOutreachPage({super.key});

  @override
  State<VHTOutreachPage> createState() => _VHTOutreachPageState();
}

class _VHTOutreachPageState extends State<VHTOutreachPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0;
  List<Map<String, dynamic>> _upcomingOutreach = [];
  List<Map<String, dynamic>> _completedOutreach = [];
  List<Map<String, dynamic>> _missedOutreach = [];
  bool _isLoading = false;

  // Update this with your actual API endpoint:
  final String apiUrl = 'https://your-backend-url.com/api/outreach';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          // 'Authorization': 'Bearer YOUR_TOKEN', // If needed
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _upcomingOutreach = data
              .where((o) => o['status'].toString().toLowerCase() == 'scheduled')
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          _completedOutreach = data
              .where((o) => o['status'].toString().toLowerCase() == 'completed')
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
          _missedOutreach = data
              .where((o) => o['status'].toString().toLowerCase() == 'missed')
              .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
              .toList();
        });
      } else {
        _showError('Failed to fetch outreach programs');
      }
    } catch (e) {
      _showError('Failed to load outreach programs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getFilteredList(List<Map<String, dynamic>> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((item) {
      return (item['title'] as String).toLowerCase().contains(q) ||
          (item['location'] as String).toLowerCase().contains(q) ||
          (item['target'] as String).toLowerCase().contains(q);
    }).toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showOutreachDetails(Map<String, dynamic> outreach) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(outreach['title'] ?? 'Outreach Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Description:', outreach['description'] ?? 'N/A'),
              _detailRow('Location:', outreach['location'] ?? 'N/A'),
              _detailRow('Date:', outreach['date'] ?? 'N/A'),
              _detailRow('Time:', outreach['time'] ?? 'N/A'),
              _detailRow('Target:', outreach['target'] ?? 'N/A'),
              _detailRow('Status:', outreach['status'] ?? 'N/A'),
              _detailRow('Coordinator:', outreach['coordinator'] ?? 'N/A'),
              if (outreach['reached'] != null)
                _detailRow('Reached:', outreach['reached'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(kSmallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, Color color) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: ElevatedButton(
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
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOutreachCard(Map<String, dynamic> o, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      elevation: 1,
      child: InkWell(
        onTap: () => _showOutreachDetails(o),
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
                      o['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      o['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                o['description'] ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      o['location'],
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(o['date'], style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 12),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(o['time'], style: const TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Target: ${o['target']}', style: const TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea(List<Map<String, dynamic>> list, Color color) {
    final filtered = _getFilteredList(list);
    if (filtered.isEmpty) {
      return const Center(child: Text('No records found.'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        return _buildOutreachCard(filtered[i], color);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outreach Programs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
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
                hintText: 'Search outreach programs...',
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
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
            const SizedBox(height: kDefaultPadding),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Upcoming',
                    _upcomingOutreach.length.toString(),
                    Icons.event,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: kSmallPadding),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    _completedOutreach.length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: kSmallPadding),
                Expanded(
                  child: _buildStatCard(
                    'Missed',
                    _missedOutreach.length.toString(),
                    Icons.event_busy,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            Row(
              children: [
                _buildTabButton('Upcoming', 0, Colors.blue),
                const SizedBox(width: kSmallPadding),
                _buildTabButton('Completed', 1, Colors.green),
                const SizedBox(width: kSmallPadding),
                _buildTabButton('Missed', 2, Colors.red),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedTabIndex == 0
                  ? _buildContentArea(_upcomingOutreach, Colors.blue)
                  : _selectedTabIndex == 1
                  ? _buildContentArea(_completedOutreach, Colors.green)
                  : _buildContentArea(_missedOutreach, Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
