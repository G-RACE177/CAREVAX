import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/visits_db.dart';
import 'services/appointments_db.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int registeredChildrenCount = 0;
  int upcomingVaccinationsCount = 0;
  int missedVaccinationsCount = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final visits = await VisitsDB.instance.readAll();
      final appointments = await AppointmentsDB.instance.readAll();

      final children = <dynamic>{};
      for (final v in visits) {
        if (v.containsKey('child_id')) children.add(v['child_id']);
      }

      final upcoming = appointments
          .where((a) => (a['status'] ?? '').toString().toLowerCase() == 'upcoming')
          .length;
      final missed = appointments
          .where((a) => (a['status'] ?? '').toString().toLowerCase() == 'missed')
          .length;

      setState(() {
        registeredChildrenCount = children.length;
        upcomingVaccinationsCount = upcoming;
        missedVaccinationsCount = missed;
      });
    } catch (e) {
      // silently use default values if DB fails
    }
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: kSmallPadding,
        vertical: kSmallPadding / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kDefaultRadius),
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          onTap();
        },
        dense: true,
      ),
    );
  }

  Widget _buildSidebarContent(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: kLargePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.health_and_safety, color: Colors.white, size: 28),
              const SizedBox(width: kSmallPadding),
              Text(
                'CareVax',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: kDefaultPadding),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: kSmallPadding),
            child: Column(
              children: [
                _sidebarItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {},
                  isActive: true,
                ),
                _sidebarItem(
                  icon: Icons.child_care,
                  title: 'Register Child',
                  onTap: () => Navigator.pushNamed(context, '/register'),
                ),
                _sidebarItem(
                  icon: Icons.vaccines,
                  title: 'Immunization History',
                  onTap: () => Navigator.pushNamed(context, '/parent/history'),
                ),
                _sidebarItem(
                  icon: Icons.notifications,
                  title: 'Reminders',
                  onTap: () => Navigator.pushNamed(context, '/parent/reminders'),
                ),
                _sidebarItem(
                  icon: Icons.description,
                  title: 'Reports',
                  onTap: () => Navigator.pushNamed(context, '/parent/reports'),
                ),
                _sidebarItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: InkWell(
            onTap: () => _logout(context),
            borderRadius: BorderRadius.circular(kDefaultRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: kDefaultPadding,
                horizontal: kDefaultPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(kDefaultRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout, color: Colors.white, size: 18),
                  SizedBox(width: kSmallPadding),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Drawer _buildSidebar(ThemeData theme) {
    return Drawer(
      child: Container(
        color: theme.colorScheme.primary,
        child: _buildSidebarContent(theme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: isSmallScreen ? _buildSidebar(theme) : null,
      appBar: isSmallScreen
          ? AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Row(
          children: const [
            Icon(Icons.health_and_safety, color: Colors.white),
            SizedBox(width: 8),
            Text('CareVax', style: TextStyle(color: Colors.white)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      )
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSmallScreen)
              Container(
                width: 250,
                color: theme.colorScheme.primary,
                child: _buildSidebarContent(theme),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parent Dashboard',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Monitor your child\'s immunization schedule',
                                style: TextStyle(
                                  color: kTextSecondary,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/parent/profile'),
                          child: CircleAvatar(
                            backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                            radius: isSmallScreen ? 20 : 24,
                            child: Icon(
                              Icons.person,
                              color: theme.colorScheme.primary,
                              size: isSmallScreen ? 20 : 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: kLargePadding),
                    _buildStatsSection(theme, isSmallScreen),
                    const SizedBox(height: kLargePadding),
                    _buildQuickActions(theme, isSmallScreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        children: [
          _statCard(
            title: 'Registered Children',
            value: registeredChildrenCount.toString(),
            icon: Icons.child_care,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: kDefaultPadding),
          _statCard(
            title: 'Upcoming Vaccinations',
            value: upcomingVaccinationsCount.toString(),
            icon: Icons.event_available,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: kDefaultPadding),
          _statCard(
            title: 'Missed Vaccinations',
            value: missedVaccinationsCount.toString(),
            icon: Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Registered Children',
            value: registeredChildrenCount.toString(),
            icon: Icons.child_care,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: kDefaultPadding),
        Expanded(
          child: _statCard(
            title: 'Upcoming Vaccinations',
            value: upcomingVaccinationsCount.toString(),
            icon: Icons.event_available,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: kDefaultPadding),
        Expanded(
          child: _statCard(
            title: 'Missed Vaccinations',
            value: missedVaccinationsCount.toString(),
            icon: Icons.warning_amber_rounded,
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(kSmallPadding),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(kDefaultRadius),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: kSmallPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kTextSecondary,
                      fontSize: 12,
                    ),
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme, bool isSmallScreen) {
    final actions = [
      {
        'title': 'Register Child',
        'description': 'Add a new child',
        'icon': Icons.person_add,
        'color': Colors.blue,
        'route': '/register'
      },
      {
        'title': 'View Schedule',
        'description': 'Upcoming immunizations',
        'icon': Icons.calendar_month,
        'color': Colors.green,
        'route': '/parent/reminders'
      },
      {
        'title': 'History',
        'description': 'Past vaccinations',
        'icon': Icons.history,
        'color': Colors.orange,
        'route': '/parent/history'
      },
      {
        'title': 'Reports',
        'description': 'Download records',
        'icon': Icons.download,
        'color': Colors.purple,
        'route': '/parent/reports'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: kDefaultPadding),
        Column(
          children: [
            // First row - 2 cards
            Row(
              children: [
                Expanded(
                  child: _quickActionCard(
                    title: actions[0]['title'] as String,
                    description: actions[0]['description'] as String,
                    icon: actions[0]['icon'] as IconData,
                    color: actions[0]['color'] as Color,
                    onTap: () => Navigator.pushNamed(
                        context, actions[0]['route'] as String),
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                Expanded(
                  child: _quickActionCard(
                    title: actions[1]['title'] as String,
                    description: actions[1]['description'] as String,
                    icon: actions[1]['icon'] as IconData,
                    color: actions[1]['color'] as Color,
                    onTap: () => Navigator.pushNamed(
                        context, actions[1]['route'] as String),
                  ),
                ),
              ],
            ),
            const SizedBox(height: kDefaultPadding),
            // Second row - 2 cards
            Row(
              children: [
                Expanded(
                  child: _quickActionCard(
                    title: actions[2]['title'] as String,
                    description: actions[2]['description'] as String,
                    icon: actions[2]['icon'] as IconData,
                    color: actions[2]['color'] as Color,
                    onTap: () => Navigator.pushNamed(
                        context, actions[2]['route'] as String),
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                Expanded(
                  child: _quickActionCard(
                    title: actions[3]['title'] as String,
                    description: actions[3]['description'] as String,
                    icon: actions[3]['icon'] as IconData,
                    color: actions[3]['color'] as Color,
                    onTap: () => Navigator.pushNamed(
                        context, actions[3]['route'] as String),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kDefaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(kSmallPadding),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: kSmallPadding),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 12,
                ),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
