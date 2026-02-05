import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class AttendanceQrScannerScreen extends StatefulWidget {
  const AttendanceQrScannerScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceQrScannerScreen> createState() =>
      _AttendanceQrScannerScreenState();
}

class _AttendanceQrScannerScreenState
    extends State<AttendanceQrScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _isScanned = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    } else if (Platform.isIOS) {
      _controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_isScanned) return;
      _isScanned = true;
      _controller?.pauseCamera();

      final code = scanData.code;
      if (code != null) {
        Navigator.of(context).pop(code);
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Attendance QR'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 16,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Point your camera at the attendance QR code.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
