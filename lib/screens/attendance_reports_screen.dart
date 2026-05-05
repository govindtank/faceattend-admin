import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceReportsScreen> createState() => _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceService>().loadAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceService = Provider.of<AttendanceService>(context);
    final records = attendanceService.records;

    final checkIns = records.where((r) => r.type == 'check_in').length;
    final checkOuts = records.where((r) => r.type == 'check_out').length;
    final uniqueEmployees = records.map((r) => r.employeeId).toSet().length;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Attendance Reports'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter by date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => attendanceService.loadAttendance(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth >= 700
                    ? (constraints.maxWidth - 48) / 4
                    : constraints.maxWidth >= 400
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _MiniStat(
                        label: 'Total Records',
                        value: '${records.length}',
                        icon: Icons.list_alt,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _MiniStat(
                        label: 'Check Ins',
                        value: '$checkIns',
                        icon: Icons.login,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _MiniStat(
                        label: 'Check Outs',
                        value: '$checkOuts',
                        icon: Icons.logout,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _MiniStat(
                        label: 'Unique Employees',
                        value: '$uniqueEmployees',
                        icon: Icons.people,
                        color: const Color(0xFF7B1FA2),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Date filter indicator
          if (_startDate != null || _endDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFE3F2FD),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Color(0xFF1565C0)),
                  const SizedBox(width: 8),
                  Text(
                    'Filtered: ${_startDate != null ? DateFormat('MMM dd').format(_startDate!) : 'Any'} '
                    '— ${_endDate != null ? DateFormat('MMM dd').format(_endDate!) : 'Any'}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF1565C0)),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      attendanceService.loadAttendance();
                    },
                    child: const Text('Clear', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),

          // Records list
          Expanded(
            child: attendanceService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text(
                              'No attendance records found',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Records will appear here when employees check in/out.',
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => attendanceService.loadAttendance(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: records.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final record = records[index];
                            final isCheckIn = record.type == 'check_in';
                            return _AttendanceRecordCard(
                              record: record,
                              isCheckIn: isCheckIn,
                              dateFormat: dateFormat,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() async {
    _startDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Start Date',
    );

    if (!mounted) return;

    _endDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select End Date',
    );

    if (!mounted) return;

    if (_startDate != null || _endDate != null) {
      setState(() {});
      context.read<AttendanceService>().loadAttendance();
    }
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceRecordCard extends StatelessWidget {
  final dynamic record;
  final bool isCheckIn;
  final DateFormat dateFormat;

  const _AttendanceRecordCard({
    required this.record,
    required this.isCheckIn,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCheckIn ? const Color(0xFF2E7D32) : const Color(0xFFE65100);
    final bgColor = isCheckIn ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Type indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCheckIn ? Icons.login : Icons.logout,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Employee info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Employee: ${record.employeeId}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(record.timestamp),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (record.location.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            record.location,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (record.deviceId.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.smartphone, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          'Device: ${record.deviceId}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Type badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCheckIn ? 'Check In' : 'Check Out',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                if (record.confidence > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 2),
                      Text(
                        '${(record.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
