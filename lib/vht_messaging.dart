import 'package:flutter/material.dart';
import 'sms_service.dart';

class VHTMessagingPage extends StatefulWidget {
  const VHTMessagingPage({Key? key}) : super(key: key);

  @override
  State<VHTMessagingPage> createState() => _VHTMessagingPageState();
}

class _VHTMessagingPageState extends State<VHTMessagingPage> {
  final SMSService _smsService = SMSService();

  final List<Map<String, String>> householdHeads = [
    {'id': 'hh1', 'name': 'John Doe', 'phone': '256700123456'},
    {'id': 'hh2', 'name': 'Jane Smith', 'phone': '256700654321'},
  ];

  final List<Map<String, String>> healthWorkers = [
    {'id': 'hw1', 'name': 'Alice Nanyonga', 'phone': '256712345678'},
    {'id': 'hw2', 'name': 'Bob Kato', 'phone': '256798765432'},
  ];

  Map<String, String>? selectedHouseholdHead;
  Map<String, String>? selectedHealthWorker;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _manualContactController = TextEditingController();

  String statusMessage = '';
  bool isSending = false;

  Future<void> sendMessage() async {
    String message = _messageController.text.trim();
    String manualContact = _manualContactController.text.trim();

    if (message.isEmpty) {
      setState(() => statusMessage = 'Please enter a message.');
      return;
    }

    if (selectedHouseholdHead == null &&
        selectedHealthWorker == null &&
        manualContact.isEmpty) {
      setState(() => statusMessage = 'Please select or enter at least one recipient.');
      return;
    }

    List<String> recipients = [];

    if (selectedHouseholdHead != null) recipients.add(selectedHouseholdHead!['phone']!);
    if (selectedHealthWorker != null) recipients.add(selectedHealthWorker!['phone']!);
    if (manualContact.isNotEmpty) recipients.add(manualContact);

    setState(() {
      isSending = true;
      statusMessage = 'Sending message...';
    });

    final result = await _smsService.sendBulkSMS(
      message: message,
      recipients: recipients,
      priority: '0',
    );

    setState(() {
      isSending = false;
      if (result['success']) {
        statusMessage = 'Message sent successfully!';
        _messageController.clear();
        _manualContactController.clear();
        selectedHouseholdHead = null;
        selectedHealthWorker = null;
      } else {
        statusMessage = 'Failed to send message: ${result['error']}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Message'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Household Head',
                style:
                    theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              DropdownButton<Map<String, String>>(
                isExpanded: true,
                value: selectedHouseholdHead,
                hint: const Text('Choose a household head'),
                items: householdHeads.map((household) {
                  return DropdownMenuItem(
                    value: household,
                    child: Text('${household['name']} (${household['phone']})'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedHouseholdHead = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Select Health Worker',
                style:
                    theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              DropdownButton<Map<String, String>>(
                isExpanded: true,
                value: selectedHealthWorker,
                hint: const Text('Choose a health worker'),
                items: healthWorkers.map((worker) {
                  return DropdownMenuItem(
                    value: worker,
                    child: Text('${worker['name']} (${worker['phone']})'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedHealthWorker = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _manualContactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Or enter phone number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Enter contact phone number',
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _messageController,
                maxLines: 5,
                maxLength: 160,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Enter your message here...',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(isSending ? 'Sending...' : 'Send Message'),
                  onPressed: isSending ? null : sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  statusMessage,
                  style: TextStyle(
                    color: statusMessage.startsWith('Failed') ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
