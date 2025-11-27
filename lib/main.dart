import 'package:flutter/material.dart';
import 'login.dart';
import 'signup.dart';
import 'parent_dashboard.dart';
import 'vht_dashboard.dart';
import 'vht_households.dart';
import 'vht_tasks.dart';
import 'vht_outreach.dart';
import 'vht_settings.dart';
import 'immunization_history_page.dart';
import 'reminders_page.dart';
import 'reports_page.dart';
import 'register_child_page.dart';
import 'theme.dart';
import 'vht_messaging.dart'; // Import this for VHTMessagingPage

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No Firestore initialization: project configured for PHP/WAMP by default.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareVax',
      theme: appTheme(),
      initialRoute: '/login',
      routes: {
        // Authentication Routes
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),

        // Parent Dashboard Routes
        '/parent': (context) => const ParentDashboard(),
        '/parent/history': (context) => const ImmunizationHistoryPage(),
        '/parent/reminders': (context) => const RemindersPage(),
        '/parent/reports': (context) => const ReportsPage(),
        '/register': (context) => const RegisterChildPage(),

        // VHT Dashboard Routes (Streamlined)
        '/vht': (context) => const VHTDashboard(),
        '/vht/households': (context) => const VHTHouseholdsPage(),
        '/vht/tasks': (context) => const VHTTasksPage(),
        '/vht/outreach': (context) => const VHTOutreachPage(),
        '/vht/settings': (context) => const VHTSettingsPage(),

        // VHT Messaging Page Route (Note: No const here to fix error)
        '/vht/messaging': (context) => VHTMessagingPage(),
      },
    );
  }
}

