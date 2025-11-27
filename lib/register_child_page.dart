import 'package:flutter/material.dart';

class RegisterChildPage extends StatefulWidget {
  const RegisterChildPage({super.key});

  @override
  _RegisterChildPageState createState() => _RegisterChildPageState();
}

class _RegisterChildPageState extends State<RegisterChildPage> {
  final _formKey = GlobalKey<FormState>();

  // Child Information
  final TextEditingController _fullNameController = TextEditingController();
  DateTime? _dob;
  String? _gender;
  final TextEditingController _birthWeightController = TextEditingController();
  final TextEditingController _placeOfBirthController = TextEditingController();

  // Parent/Guardian
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Health Facility
  final TextEditingController _facilityNameController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  // Vaccines map
  final Map<String, bool> _vaccines = {
    'BCG (at birth)': false,
    'OPV 0 (at birth)': false,
    'OPV 1': false,
    'OPV 2': false,
    'OPV 3': false,
    'DPT-HepB-Hib (Pentavalent 1)': false,
    'DPT-HepB-Hib (Pentavalent 2)': false,
    'DPT-HepB-Hib (Pentavalent 3)': false,
    'PCV 1': false,
    'PCV 2': false,
    'PCV 3': false,
    'Rotavirus 1': false,
    'Rotavirus 2': false,
    'Measles-Rubella (9 months)': false,
    'Measles-Rubella (18 months)': false,
    'Yellow Fever (9 months, some regions)': false,
    'HPV (Girls 9–14 years)': false,
  };

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 2));
    final DateTime first = DateTime(2000);
    final DateTime last = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final selectedVaccines = _vaccines.entries.where((e) => e.value).map((e) => e.key).toList();

    final summary = StringBuffer();
    summary.writeln('Child: ${_fullNameController.text}');
    summary.writeln('DOB: ${_dob != null ? '${_dob!.day}/${_dob!.month}/${_dob!.year}' : 'Not set'}');
    summary.writeln('Gender: ${_gender ?? 'Not set'}');
    summary.writeln('Birth weight: ${_birthWeightController.text} kg');
    summary.writeln('Place of birth: ${_placeOfBirthController.text}');
    summary.writeln('Mother: ${_motherNameController.text}');
    summary.writeln('Father/Guardian: ${_fatherNameController.text}');
    summary.writeln('Contact: ${_contactNumberController.text}');
    summary.writeln('Address: ${_addressController.text}');
    summary.writeln('Health facility: ${_facilityNameController.text}');
    summary.writeln('District: ${_districtController.text}');
    summary.writeln('Vaccines given: ${selectedVaccines.isEmpty ? 'None' : selectedVaccines.join(', ')}');

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registered ${_fullNameController.text}')));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registration Summary'),
        content: SingleChildScrollView(child: Text(summary.toString())),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Registration Form')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text('Child Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: "Child's Full Name", border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter full name' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDOB(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Date of Birth'),
                          child: Text(_dob == null ? 'dd/mm/yyyy' : '${_dob!.day}/${_dob!.month}/${_dob!.year}'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Gender'),
                        hint: const Text('--Select--'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _gender = v),
                        validator: (v) => (v == null || v.isEmpty) ? 'Please select gender' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _birthWeightController,
                  decoration: const InputDecoration(labelText: 'Birth Weight (kg)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _placeOfBirthController,
                  decoration: const InputDecoration(labelText: 'Place of Birth', border: OutlineInputBorder()),
                ),

                const SizedBox(height: 16),
                const Text('Parent/Guardian Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _motherNameController,
                  decoration: const InputDecoration(labelText: "Mother's Name", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fatherNameController,
                  decoration: const InputDecoration(labelText: "Father/Guardian's Name", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contactNumberController,
                  decoration: const InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address/Village', border: OutlineInputBorder()),
                ),

                const SizedBox(height: 16),
                const Text('Health Facility Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _facilityNameController,
                  decoration: const InputDecoration(labelText: 'Health Facility Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _districtController,
                  decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()),
                ),

                const SizedBox(height: 16),
                const Text('Vaccination Schedule & Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Select vaccines already given to this child:'),
                const SizedBox(height: 8),
                ..._vaccines.keys.map((k) {
                  return CheckboxListTile(
                    title: Text(k),
                    value: _vaccines[k],
                    onChanged: (v) => setState(() => _vaccines[k] = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }),

                const SizedBox(height: 16),
                ElevatedButton(onPressed: _submit, child: const Text('Register Child')),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
