import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/theme.dart';
import 'attendance_history_screen.dart';
import 'attendance_qr_scanner_screen.dart';

class AttendanceFormScreen extends StatefulWidget {
  const AttendanceFormScreen({Key? key}) : super(key: key);

  @override
  _AttendanceFormScreenState createState() => _AttendanceFormScreenState();
}

class _AttendanceFormScreenState extends State<AttendanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submitAttendance() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      double? latitude;
      double? longitude;

      // Ambil lokasi terlebih dahulu
      try {
        final position = await _determinePosition();
        latitude = position.latitude;
        longitude = position.longitude;
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString();
          });
        }
        return;
      }

      try {
        final attendanceProvider =
            Provider.of<AttendanceProvider>(context, listen: false);
        final success = await attendanceProvider.submitAttendance(
          _pinController.text.trim(),
          latitude: latitude,
          longitude: longitude,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            if (success) {
              _successMessage = 'Attendance recorded successfully!';
              _pinController.clear();
            } else {
              _errorMessage =
                  attendanceProvider.error ?? 'Failed to submit attendance';
            }
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceQrScannerScreen(),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _pinController.text = result;
      });
      // Opsional: langsung submit setelah scan
      // _submitAttendance();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          'Location services are disabled. Please enable location.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
            'Location permission denied. Please allow location access.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission permanently denied. Please enable it in settings.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Attendance icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Submit Attendance',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Enter the attendance PIN provided by your teacher to record your attendance for today\'s class.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Scan QR button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _scanQrCode,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Attendance'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 24),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),

                // Success message
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                  ),

                // PIN input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance PIN',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '• • • • • •',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the attendance PIN';
                        }
                        if (value.length != 6) {
                          return 'PIN must be 6 digits';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitAttendance,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // View history button
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceHistoryScreen(),
                      ),
                    );
                  },
                  child: const Text('View Attendance History'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
