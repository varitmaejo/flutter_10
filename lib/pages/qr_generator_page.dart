import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGeneratorPage extends StatefulWidget {
  const QrGeneratorPage({super.key});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  // Controller สำหรับรับข้อมูลจาก TextField
  final TextEditingController _textController = TextEditingController();
  // ตัวแปรสำหรับเก็บข้อความที่จะนำไปสร้าง QR Code
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    // เริ่มต้นให้ qrData มีค่าว่าง
    _qrData = '';
    // เพิ่ม Listener ให้กับ Controller เพื่ออัปเดต UI ทันทีที่ผู้ใช้พิมพ์
    _textController.addListener(() {
      setState(() {
        _qrData = _textController.text;
      });
    });
  }

  @override
  void dispose() {
    // ยกเลิกการใช้งาน Controller เมื่อ Widget ถูกทำลาย
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้าง QR Code'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ป้อนข้อความหรือลิงก์เพื่อสร้าง QR Code',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // ช่องสำหรับกรอกข้อความ
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'ข้อมูลสำหรับ QR Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            // ตรวจสอบว่ามีข้อมูลที่จะสร้าง QR Code หรือไม่
            if (_qrData.isNotEmpty)
              Column(
                children: [
                  const Text('นี่คือ QR Code ของคุณ:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  // ใช้ Widget จากแพ็กเกจ qr_flutter เพื่อสร้าง QR Code
                  QrImageView(
                    data: _qrData, // ข้อมูลที่ต้องการแปลง
                    version: QrVersions.auto, // กำหนดเวอร์ชันอัตโนมัติ
                    size: 200.0, // ขนาดของ QR Code
                    backgroundColor: Colors.white,
                  ),
                ],
              )
            else
            // แสดงข้อความแนะนำเมื่อยังไม่มีข้อมูล
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'QR Code จะแสดงที่นี่',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}