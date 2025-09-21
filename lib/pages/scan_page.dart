import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

// ส่วนประกอบ UI สำหรับ Overlay ที่ไม่ได้อยู่ใน PDF แต่จำเป็น
class QrScannerOverlayShape extends StatelessWidget {
  const QrScannerOverlayShape({
    super.key,
    this.borderColor = Colors.green,
    this.borderRadius = 10,
    this.borderLength = 30,
    this.borderWidth = 10,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: cutOutSize,
                    height: cutOutSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(0),
          child: Center(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(
                borderColor: borderColor,
                borderRadius: borderRadius,
                borderLength: borderLength,
                borderWidth: borderWidth,
                cutOutSize: cutOutSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  });

  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Draw corners
    canvas.drawPath(
      Path()
        ..moveTo(rrect.left, rrect.top + borderLength)
        ..lineTo(rrect.left, rrect.top)
        ..lineTo(rrect.left + borderLength, rrect.top),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rrect.right - borderLength, rrect.top)
        ..lineTo(rrect.right, rrect.top)
        ..lineTo(rrect.right, rrect.top + borderLength),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rrect.right, rrect.bottom - borderLength)
        ..lineTo(rrect.right, rrect.bottom)
        ..lineTo(rrect.right - borderLength, rrect.bottom),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rrect.left + borderLength, rrect.bottom)
        ..lineTo(rrect.left, rrect.bottom)
        ..lineTo(rrect.left, rrect.bottom - borderLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  late MobileScannerController _controller;
  BarcodeCapture? _barcodeCapture;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  void _onBarcodeDetect(BarcodeCapture barcodeCapture) {
    if (mounted) {
      setState(() {
        _barcodeCapture = barcodeCapture;
      });
      _controller.stop();
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    if (_barcodeCapture?.barcodes.isNotEmpty == true) {
      final barcode = _barcodeCapture!.barcodes.first;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ผลการสแกน'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ประเภท: ${barcode.format.name}'),
                const SizedBox(height: 10),
                Text('ข้อมูล: ${barcode.displayValue ?? 'ไม่มีข้อมูล'}'),
                if (barcode.displayValue?.startsWith('http') == true)
                  const SizedBox(height: 10),
                if (barcode.displayValue?.startsWith('http') == true)
                  ElevatedButton(
                    onPressed: () => _launchURL(barcode.displayValue!),
                    child: const Text('เปิดลิงก์'),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetScanner();
                },
                child: const Text('สแกนใหม่'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // ไม่จำเป็นต้อง pop สองครั้ง ถ้าเราไม่ได้ push หน้าใหม่มา
                },
                child: const Text('ปิด'),
              ),
            ],
          );
        },
      );
    }
  }

  void _resetScanner() {
    setState(() {
      _barcodeCapture = null;
    });
    _controller.start();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถเปิดลิงก์ได้')),
        );
      }
    }
  }

  void _toggleFlash() {
    _controller.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  void _switchCamera() {
    _controller.switchCamera();
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกนด้วยกล้อง'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
          ),
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.flip_camera_android),
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _requestPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data != true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('กรุณาอนุญาตการเข้าถึงกล้อง'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => openAppSettings(),
                    child: const Text('เปิดการตั้งค่า'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onBarcodeDetect,
              ),
              QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      _barcodeCapture == null
                          ? 'วางกล้องให้อยู่เหนือ QR Code หรือ Barcode'
                          : 'ข้อมูล: ${_barcodeCapture!.barcodes.first.displayValue ?? 'ไม่มีข้อมูล'}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}