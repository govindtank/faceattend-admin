import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AttendanceRecord {
  final String id;
  final String employeeId;
  final DateTime timestamp;
  final String type; // 'check_in' or 'check_out'
  final double confidence;
  final String location;
  final String deviceId;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.timestamp,
    required this.type,
    this.confidence = 0.0,
    this.location = '',
    this.deviceId = '',
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] ?? '',
        employeeId: json['employeeId'] ?? json['employee_id'] ?? '',
        timestamp: DateTime.parse(
            json['timestamp'] ?? DateTime.now().toIso8601String()),
        type: json['type'] ?? 'check_in',
        confidence: (json['confidence'] ?? 0.0).toDouble(),
        location: json['location'] ?? '',
        deviceId: json['deviceId'] ?? json['device_id'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'confidence': confidence,
        'location': location,
        'deviceId': deviceId,
      };
}

class AttendanceService extends ChangeNotifier {
  List<AttendanceRecord> _records = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAttendance({String? employeeId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse('http://localhost:5000/api/attendance/reports')
          .replace(queryParameters: {
        if (employeeId != null) 'employeeId': employeeId,
      });

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _records =
            data.map((json) => AttendanceRecord.fromJson(json)).toList();
      } else {
        _errorMessage = 'Failed to load attendance records';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordAttendance({
    required String employeeId,
    required String type,
    double confidence = 0.0,
    String location = '',
    String deviceId = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employeeId': employeeId,
          'type': type,
          'confidence': confidence,
          'location': location,
          'deviceId': deviceId,
        }),
      );

      final success = response.statusCode == 201;
      if (!success) {
        _errorMessage = 'Failed to record attendance';
      }
      return success;
    } catch (e) {
      _errorMessage = 'Network error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
