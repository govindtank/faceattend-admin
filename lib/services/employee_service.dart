import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';

class EmployeeService extends ChangeNotifier {
  List<Employee> _employees = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEmployees() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API endpoint
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/employees'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${authService.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _employees = data.map((json) => Employee.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load employees';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEmployee(Employee employee) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/employees'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${authService.token}',
        },
        body: jsonEncode(employee.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newEmployee = Employee.fromJson(data);
        _employees.add(newEmployee);
        return true;
      } else {
        _errorMessage = 'Failed to add employee';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}