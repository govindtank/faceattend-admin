import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/employee_service.dart';
import '../services/attendance_service.dart';
import 'employee_management_screen.dart';
import 'attendance_reports_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeService>().loadEmployees();
      context.read<AttendanceService>().loadAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'FaceAttend Admin',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showSnackBar('No new notifications'),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EmployeeService>().loadEmployees();
              context.read<AttendanceService>().loadAttendance();
            },
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isWide ? null : _buildDrawer(context),
      body: isWide ? _buildDesktopBody(context) : _buildMobileBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.face, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'FaceAttend Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Administrator',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: _selectedNavIndex == 0,
                  onTap: () {
                    setState(() => _selectedNavIndex = 0);
                    Navigator.pop(context);
                  },
                ),
                _DrawerItem(
                  icon: Icons.people_rounded,
                  label: 'Employees',
                  isSelected: _selectedNavIndex == 1,
                  onTap: () {
                    setState(() => _selectedNavIndex = 1);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployeeManagementScreen(),
                      ),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Attendance Reports',
                  isSelected: _selectedNavIndex == 2,
                  onTap: () {
                    setState(() => _selectedNavIndex = 2);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AttendanceReportsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: _selectedNavIndex == 3,
                  onTap: () {
                    setState(() => _selectedNavIndex = 3);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                context.read<AuthService>().logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Row(
      children: [
        _buildSideNav(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: _buildDashboardContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSideNav(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _SideNavItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isSelected: _selectedNavIndex == 0,
            onTap: () => setState(() => _selectedNavIndex = 0),
          ),
          _SideNavItem(
            icon: Icons.people_rounded,
            label: 'Employees',
            isSelected: _selectedNavIndex == 1,
            onTap: () {
              setState(() => _selectedNavIndex = 1);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployeeManagementScreen(),
                ),
              );
            },
          ),
          _SideNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Attendance',
            isSelected: _selectedNavIndex == 2,
            onTap: () {
              setState(() => _selectedNavIndex = 2);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AttendanceReportsScreen(),
                ),
              );
            },
          ),
          const Divider(indent: 12, endIndent: 12, height: 32),
          _SideNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            isSelected: _selectedNavIndex == 3,
            onTap: () {
              setState(() => _selectedNavIndex = 3);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const Spacer(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red, size: 20),
              title: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 14)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                context.read<AuthService>().logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildDashboardContent(context),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final employeeService = Provider.of<EmployeeService>(context);
    final attendanceService = Provider.of<AttendanceService>(context);

    final totalEmployees = employeeService.employees.length;
    final activeToday = attendanceService.records
        .where((r) =>
            r.timestamp.day == DateTime.now().day &&
            r.timestamp.month == DateTime.now().month &&
            r.timestamp.year == DateTime.now().year &&
            r.type == 'check_in')
        .map((r) => r.employeeId)
        .toSet()
        .length;
    final totalRecords = attendanceService.records.length;
    final activeEmployees = employeeService.employees.where((e) => e.isActive).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome header
        Text(
          'Welcome back, Admin',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s what\'s happening with your team today.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 28),

        // Stats cards
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 800
                ? (constraints.maxWidth - 48) / 4
                : constraints.maxWidth >= 500
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _StatCard(
                    title: 'Total Employees',
                    value: '$totalEmployees',
                    subtitle: 'Registered members',
                    icon: Icons.people_rounded,
                    color: const Color(0xFF1565C0),
                    iconBg: const Color(0xFFE3F2FD),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _StatCard(
                    title: 'Active Today',
                    value: '$activeToday',
                    subtitle: 'Checked in today',
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF2E7D32),
                    iconBg: const Color(0xFFE8F5E9),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _StatCard(
                    title: 'Total Records',
                    value: '$totalRecords',
                    subtitle: 'Attendance logs',
                    icon: Icons.history_rounded,
                    color: const Color(0xFFE65100),
                    iconBg: const Color(0xFFFFF3E0),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _StatCard(
                    title: 'Active Staff',
                    value: '$activeEmployees',
                    subtitle: 'Currently enabled',
                    icon: Icons.verified_user_rounded,
                    color: const Color(0xFF7B1FA2),
                    iconBg: const Color(0xFFF3E5F5),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // Quick actions
        _SectionTitle(
          title: 'Quick Actions',
          action: TextButton(
            onPressed: () {},
            child: const Text('View All'),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionButton(
              icon: Icons.person_add_rounded,
              label: 'Add Employee',
              color: const Color(0xFF1565C0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeManagementScreen(),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.assessment_rounded,
              label: 'View Reports',
              color: const Color(0xFF2E7D32),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceReportsScreen(),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.calendar_today_rounded,
              label: 'Attendance',
              color: const Color(0xFFE65100),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendanceReportsScreen(),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.settings_rounded,
              label: 'Settings',
              color: const Color(0xFF7B1FA2),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Recent employees
        _SectionTitle(
          title: 'Recent Employees',
          action: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployeeManagementScreen(),
                ),
              );
            },
            child: const Text('View All'),
          ),
        ),
        const SizedBox(height: 12),
        if (employeeService.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (employeeService.employees.isEmpty)
          _EmptyState(
            icon: Icons.people_outline,
            title: 'No employees yet',
            subtitle: 'Add your first employee to get started.',
            actionLabel: 'Add Employee',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmployeeManagementScreen(),
                ),
              );
            },
          )
        else
          _buildRecentEmployees(employeeService.employees.take(5).toList()),
      ],
    );
  }

  Widget _buildRecentEmployees(List employees) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < employees.length; i++) ...[
            _EmployeeListTile(employee: employees[i]),
            if (i < employees.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}

// ─── Reusable Widgets ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconBg;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: Colors.grey.shade400, size: 18),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionTitle({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeListTile extends StatelessWidget {
  final dynamic employee;
  const _EmployeeListTile({required this.employee});

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor(employee.name);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: avatarColor.withOpacity(0.15),
        child: Text(
          employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: avatarColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        employee.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        '${employee.department} · ${employee.position}',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: employee.isActive
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          employee.isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: employee.isActive ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFFE65100),
      const Color(0xFF7B1FA2),
      const Color(0xFFC62828),
      const Color(0xFF00838F),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade600,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade800,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        selectedTileColor: const Color(0xFFE3F2FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade600,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        selectedTileColor: const Color(0xFFE3F2FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
