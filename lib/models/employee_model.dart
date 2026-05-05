class Employee {
  final String id;
  final String name;
  final String department;
  final String position;
  final String email;
  final String phone;
  final DateTime createdAt;
  bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.position,
    this.email = '',
    this.phone = '',
    required this.createdAt,
    this.isActive = true,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'],
        name: json['name'],
        department: json['department'],
        position: json['position'],
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'department': department,
        'position': position,
        'email': email,
        'phone': phone,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
      };
}