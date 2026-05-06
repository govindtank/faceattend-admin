import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_panel/services/auth_service.dart';
import 'package:admin_panel/services/employee_service.dart';
import 'package:admin_panel/services/attendance_service.dart';
import 'package:admin_panel/screens/login_screen.dart';
import 'package:admin_panel/screens/dashboard_screen.dart';
import 'package:admin_panel/screens/employee_management_screen.dart';
import 'package:admin_panel/screens/attendance_reports_screen.dart';
import 'package:admin_panel/screens/settings_screen.dart';

void main() {
  runApp(const FaceAttendAdminApp());
}

class FaceAttendAdminApp extends StatelessWidget {
  const FaceAttendAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => EmployeeService()),
        ChangeNotifierProvider(create: (_) => AttendanceService()),
      ],
      child: MaterialApp(
        title: 'FaceAttend Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1565C0),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Color(0xFF1565C0)),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1565C0),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1565C0),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          dividerTheme: DividerThemeData(
            color: Colors.grey.shade200,
            thickness: 1,
          ),
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
        ),
        home: const LoginScreen(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/employees': (context) => const EmployeeManagementScreen(),
          '/attendance': (context) => const AttendanceReportsScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
