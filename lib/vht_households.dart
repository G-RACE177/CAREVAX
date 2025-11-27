import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'theme.dart';

class VHTHouseholdsPage extends StatefulWidget {
  const VHTHouseholdsPage({super.key});

  @override
  State<VHTHouseholdsPage> createState() => _VHTHouseholdsPageState();
}

class _VHTHouseholdsPageState extends State<VHTHouseholdsPage> {
  List<Map<String, dynamic>> _households = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

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
      // TODO: Replace with actual API endpoint
      // final response = await http.get(Uri.parse('YOUR_API_URL/households'));
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body) as List;
      //   setState(() {
      //     _households = data.map((e) => Map<String, dynamic>.from(e)).toList();
      //   });
      // }

      // Temporary local data
      setState(() {
        _households = [];
      });
    } catch (e) {
      _showError('Failed to load households: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredHouseholds {
    if (_searchQuery.isEmpty) return _households;
    final query = _searchQuery.toLowerCase();
    return _households.where((h) {
      final name = (h['householdName'] ?? '').toString().toLowerCase();
      final location = (h['location'] ?? '').toString().toLowerCase();
      return name.contains(query) || location.contains(query);
    }).toList();
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled. Please enable them.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError('Location permissions are permanently denied');
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _showError('Failed to get location: $e');
      return null;
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

  void _showAddHouseholdDialog() async {
    final position = await _getCurrentLocation();
    if (position == null) return;

    final formKey = GlobalKey<FormState>();
    final householdNameController = TextEditingController();
    final headOfHouseholdController = TextEditingController();
    final contactController = TextEditingController();
    final membersController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Household'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(position.latitude, position.longitude),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: LatLng(position.latitude, position.longitude),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Latitude: ${position.latitude.toStringAsFixed(6)}\nLongitude: ${position.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: householdNameController,
                  decoration: const InputDecoration(labelText: 'Household Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: headOfHouseholdController,
                  decoration: const InputDecoration(labelText: 'Head of Household'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Contact Number'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: membersController,
                  decoration: const InputDecoration(labelText: 'Number of Members'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (int.tryParse(v) == null) return 'Enter valid number';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              householdNameController.dispose();
              headOfHouseholdController.dispose();
              contactController.dispose();
              membersController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final household = {
                  'householdName': householdNameController.text.trim(),
                  'headOfHousehold': headOfHouseholdController.text.trim(),
                  'contact': contactController.text.trim(),
                  'members': int.parse(membersController.text.trim()),
                  'latitude': position.latitude,
                  'longitude': position.longitude,
                  'location':
                      '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                  'children': [],
                  'registeredAt': DateTime.now().toIso8601String(),
                };

                // TODO: Send household data to API here

                setState(() {
                  _households.add(household);
                });

                householdNameController.dispose();
                headOfHouseholdController.dispose();
                contactController.dispose();
                membersController.dispose();
                Navigator.pop(context);

                _showSuccess('Household registered successfully');
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  void _showAddChildDialog(Map<String, dynamic> household) {
    final formKey = GlobalKey<FormState>();
    final childNameController = TextEditingController();
    String? gender;
    DateTime? selectedDOB;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Register Child'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Household: ${household['householdName']}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: childNameController,
                    decoration:
                        const InputDecoration(labelText: 'Child Full Name'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => gender = v),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(
                      selectedDOB == null
                          ? 'Select Date of Birth'
                          : 'DOB: ${selectedDOB!.day}/${selectedDOB!.month}/${selectedDOB!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final dob = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().subtract(const Duration(days: 365)),
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365 * 5)),
                        lastDate: DateTime.now(),
                      );
                      if (dob != null) {
                        setDialogState(() {
                          selectedDOB = dob;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                childNameController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }
                if (selectedDOB == null) {
                  _showError('Please select date of birth');
                  return;
                }

                final now = DateTime.now();
                final age = now.year -
                    selectedDOB!.year -
                    ((now.month < selectedDOB!.month ||
                            (now.month == selectedDOB!.month &&
                                now.day < selectedDOB!.day))
                        ? 1
                        : 0);

                if (age >= 5) {
                  _showError('Child must be under 5 years old');
                  return;
                }

                final child = {
                  'name': childNameController.text.trim(),
                  'gender': gender,
                  'dob': selectedDOB!.toIso8601String(),
                  'age': age,
                  'registeredAt': DateTime.now().toIso8601String(),
                };

                // TODO: Send child data to API here

                setState(() {
                  household['children'] = household['children'] ?? [];
                  (household['children'] as List).add(child);
                });

                childNameController.dispose();
                Navigator.pop(context);

                _showSuccess('Child registered successfully');
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewHouseholdDetails(Map<String, dynamic> household) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(household['householdName'] ?? 'Household Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Head:', household['headOfHousehold'] ?? 'N/A'),
              _detailRow('Contact:', household['contact'] ?? 'N/A'),
              _detailRow('Members:', household['members']?.toString() ?? '0'),
              _detailRow('Location:', household['location'] ?? 'N/A'),
              const Divider(),
              const Text('Children:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (household['children'] == null || (household['children'] as List).isEmpty)
                const Text('No children registered', style: TextStyle(color: Colors.grey))
              else
                ...(household['children'] as List).map((child) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(child['name'][0].toUpperCase()),
                    ),
                    title: Text(child['name']),
                    subtitle: Text('${child['gender']} - Age: ${child['age']} years'),
                  ),
                )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddChildDialog(household);
            },
            child: const Text('Add Child'),
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
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kLargePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Registered Households',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: kSmallPadding),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search households...',
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            Card(
              elevation: 0,
              color: theme.colorScheme.primary.withAlpha(12),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Households', _households.length.toString(), Icons.home),
                    _statItem(
                      'Total Children',
                      _households
                          .fold<int>(
                        0,
                            (sum, h) =>
                        sum + ((h['children'] as List?)?.length ?? 0),
                      )
                          .toString(),
                      Icons.child_care,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: kDefaultPadding),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredHouseholds.isEmpty
                  ? const Center(child: Text('No households registered yet'))
                  : ListView.builder(
                itemCount: _filteredHouseholds.length,
                itemBuilder: (context, index) {
                  final household = _filteredHouseholds[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: kDefaultPadding),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          household['householdName']
                              .toString()[0]
                              .toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        household['householdName'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Head: ${household['headOfHousehold']} | Members: ${household['members']} | Children: ${(household['children'] as List?)?.length ?? 0}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, color: Colors.blue),
                            onPressed: () => _viewHouseholdDetails(household),
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_add, color: Colors.green),
                            onPressed: () => _showAddChildDialog(household),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_location),
        label: const Text('Register Household'),
        onPressed: _showAddHouseholdDialog,
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
