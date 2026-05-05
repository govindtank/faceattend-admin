import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/employee_service.dart';
import '../models/employee_model.dart';

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeService>().loadEmployees();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Employee> _filteredEmployees(List<Employee> employees) {
    if (_searchQuery.isEmpty) return employees;
    final q = _searchQuery.toLowerCase();
    return employees.where((e) =>
      e.name.toLowerCase().contains(q) ||
      e.department.toLowerCase().contains(q) ||
      e.position.toLowerCase().contains(q) ||
      e.email.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final employeeService = Provider.of<EmployeeService>(context);
    final filtered = _filteredEmployees(employeeService.employees);
    final isWide = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Employee Management'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & filter bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
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
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'All (${employeeService.employees.length})',
                  isSelected: true,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Active (${employeeService.employees.where((e) => e.isActive).length})',
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: employeeService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : isWide
                        ? _buildDataTable(filtered, employeeService)
                        : _buildMobileList(filtered, employeeService),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No results found' : 'No employees yet',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Add your first employee to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Employee'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataTable(List<Employee> employees, EmployeeService service) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: const [
                SizedBox(width: 44, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey))),
                Expanded(flex: 3, child: Text('Employee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('Department', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('Position', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                SizedBox(width: 120, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                SizedBox(width: 100, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              ],
            ),
          ),
          // Table rows
          Expanded(
            child: ListView.separated(
              itemCount: employees.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, index) {
                final e = employees[index];
                return _DataTableRow(
                  employee: e,
                  index: index,
                  onEdit: () => _showEditDialog(context, e),
                  onToggle: () async {
                    e.isActive = !e.isActive;
                    await service.addEmployee(e);
                  },
                  onDelete: () => _showDeleteDialog(context, e, service),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<Employee> employees, EmployeeService service) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: employees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final e = employees[index];
        return _EmployeeCard(
          employee: e,
          onEdit: () => _showEditDialog(context, e),
          onToggle: () async {
            e.isActive = !e.isActive;
            await service.addEmployee(e);
          },
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final deptController = TextEditingController();
    final posController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.person_add, color: Color(0xFF1565C0)),
            SizedBox(width: 10),
            Text('Add Employee'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deptController,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: posController,
                  decoration: const InputDecoration(
                    labelText: 'Position *',
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  deptController.text.isEmpty ||
                  posController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              final employee = Employee(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                department: deptController.text,
                position: posController.text,
                email: emailController.text,
                phone: phoneController.text,
                createdAt: DateTime.now(),
              );
              await context.read<EmployeeService>().addEmployee(employee);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Employee added successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Add Employee'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Employee employee) {
    final nameController = TextEditingController(text: employee.name);
    final deptController = TextEditingController(text: employee.department);
    final posController = TextEditingController(text: employee.position);
    final emailController = TextEditingController(text: employee.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.edit, color: Color(0xFF1565C0)),
            SizedBox(width: 10),
            Text('Edit Employee'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.business)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: posController,
                  decoration: const InputDecoration(labelText: 'Position', prefixIcon: Icon(Icons.work)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = Employee(
                id: employee.id,
                name: nameController.text,
                department: deptController.text,
                position: posController.text,
                email: emailController.text,
                phone: employee.phone,
                createdAt: employee.createdAt,
                isActive: employee.isActive,
              );
              await context.read<EmployeeService>().addEmployee(updated);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Employee updated'), behavior: SnackBarBehavior.floating),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Employee employee, EmployeeService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to remove ${employee.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Remove locally (API would handle this)
              service.employees.removeWhere((e) => e.id == employee.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${employee.name} removed'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFFE3F2FD) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DataTableRow extends StatelessWidget {
  final Employee employee;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _DataTableRow({
    required this.employee,
    required this.index,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getColor(employee.name);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              '${index + 1}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: avatarColor.withOpacity(0.15),
                  child: Text(
                    employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                    style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    employee.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(employee.department, style: const TextStyle(fontSize: 14))),
          Expanded(flex: 2, child: Text(employee.position, style: const TextStyle(fontSize: 14))),
          Expanded(
            flex: 2,
            child: Text(
              employee.email.isNotEmpty ? employee.email : '—',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: employee.isActive ? Colors.green.shade50 : Colors.grey.shade100,
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
                const SizedBox(width: 8),
                Switch(
                  value: employee.isActive,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF1565C0)),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String name) {
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

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  const _EmployeeCard({
    required this.employee,
    required this.onEdit,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getColor(employee.name);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColor.withOpacity(0.15),
                  child: Text(
                    employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                    style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${employee.department} · ${employee.position}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: employee.isActive ? Colors.green.shade50 : Colors.grey.shade100,
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
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (employee.email.isNotEmpty) ...[
                  Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(employee.email, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 16),
                ],
                if (employee.phone.isNotEmpty) ...[
                  Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(employee.phone, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    employee.isActive ? Icons.toggle_on : Icons.toggle_off,
                    size: 18,
                  ),
                  label: Text(employee.isActive ? 'Deactivate' : 'Activate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String name) {
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
