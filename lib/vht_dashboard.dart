import 'package:flutter/material.dart';
// Removed unused imports (geolocator/http) to avoid analyzer warnings.
import 'theme.dart';

class VHTDashboard extends StatefulWidget {
  const VHTDashboard({super.key});

  @override
  State<VHTDashboard> createState() => _VHTDashboardState();
}

class _VHTDashboardState extends State<VHTDashboard> {
  int totalHouseholds = 0;
  int totalChildren = 0;
  int pendingTasks = 0;
  int upcomingOutreach = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load dashboard statistics
      // This will be updated to fetch from backend API
      setState(() {
        totalHouseholds = 0; // Replace with API call
        totalChildren = 0;
        pendingTasks = 0;
        upcomingOutreach = 0;
      });
    } catch (e) {
      // Silently handle errors
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
              const Icon(Icons.medical_services, color: Colors.white, size: 28),
              const SizedBox(width: kSmallPadding),
              Text(
                'CareVax VHT',
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
            child: Column(
              children: [
                _sidebarItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {},
                  isActive: true,
                ),
                _sidebarItem(
                  icon: Icons.home_work,
                  title: 'Households',
                  onTap: () => Navigator.pushNamed(context, '/vht/households'),
                ),
                _sidebarItem(
                  icon: Icons.task_alt,
                  title: 'Tasks',
                  onTap: () => Navigator.pushNamed(context, '/vht/tasks'),
                ),
                _sidebarItem(
                  icon: Icons.campaign,
                  title: 'Outreach Programs',
                  onTap: () => Navigator.pushNamed(context, '/vht/outreach'),
                ),
                _sidebarItem(
                  icon: Icons.message,
                  title: 'Messaging',
                  onTap: () => Navigator.pushNamed(context, '/vht/messaging'),
                ),
                _sidebarItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () => Navigator.pushNamed(context, '/vht/settings'),
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white, size: 18),
                  SizedBox(width: kSmallPadding),
                  Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
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
              title: const Row(
                children: [
                  Icon(Icons.medical_services, color: Colors.white),
                  SizedBox(width: 8),
                  Text('CareVax VHT', style: TextStyle(color: Colors.white)),
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
                    Text(
                      'VHT Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    const SizedBox(height: kDefaultPadding),
                    _buildStatsRow(theme, isSmallScreen),
                    const SizedBox(height: kLargePadding),
                    _buildQuickActionsGrid(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, bool isSmallScreen) {
    if (isSmallScreen) {
      return Column(
        children: [
          _statCard(
            title: 'Total Households',
            value: totalHouseholds.toString(),
            icon: Icons.home,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: kDefaultPadding),
          _statCard(
            title: 'Children Registered',
            value: totalChildren.toString(),
            icon: Icons.child_care,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: kDefaultPadding),
          _statCard(
            title: 'Pending Tasks',
            value: pendingTasks.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
          const SizedBox(height: kDefaultPadding),
          _statCard(
            title: 'Upcoming Outreach',
            value: upcomingOutreach.toString(),
            icon: Icons.event,
            color: Colors.purple,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Total Households',
            value: totalHouseholds.toString(),
            icon: Icons.home,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: kDefaultPadding),
        Expanded(
          child: _statCard(
            title: 'Children Registered',
            value: totalChildren.toString(),
            icon: Icons.child_care,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: kDefaultPadding),
        Expanded(
          child: _statCard(
            title: 'Pending Tasks',
            value: pendingTasks.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: kDefaultPadding),
        Expanded(
          child: _statCard(
            title: 'Upcoming Outreach',
            value: upcomingOutreach.toString(),
            icon: Icons.event,
            color: Colors.purple,
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
                      fontSize: 12,
                      color: kTextSecondary,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: kDefaultPadding),
        // 2x2 Grid - First Row
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.home_work,
                title: 'Households',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/vht/households'),
              ),
            ),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: _quickActionCard(
                icon: Icons.message,
                title: 'Messaging',
                color: Colors.teal,
                onTap: () => Navigator.pushNamed(context, '/vht/messaging'),
              ),
            ),
          ],
        ),
        const SizedBox(height: kDefaultPadding),
        // 2x2 Grid - Second Row
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.task_alt,
                title: 'Tasks',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/vht/tasks'),
              ),
            ),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: _quickActionCard(
                icon: Icons.campaign,
                title: 'Outreach',
                color: Colors.orange,
                onTap: () => Navigator.pushNamed(context, '/vht/outreach'),
              ),
            ),
          ],
        ),
        const SizedBox(height: kDefaultPadding),
        Row(
          children: [
            Expanded(
              child: _quickActionCard(
                icon: Icons.settings,
                title: 'Settings',
                color: Colors.purple,
                onTap: () => Navigator.pushNamed(context, '/vht/settings'),
              ),
            ),
            const SizedBox(width: kDefaultPadding),
            Expanded(child: Container()), // Empty space
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(kSmallPadding),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(kDefaultRadius),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: kSmallPadding),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
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
