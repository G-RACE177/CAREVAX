import 'package:flutter/material.dart';
import 'theme.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports'), backgroundColor: kSecondaryColor),
      body: const Center(child: Text('This is the Reports page')),
    );
  }
}
