import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // ตัวแปรสำหรับเก็บไฟล์รูปภาพที่ถ่าย
  File? _image;
  // Instance ของ ImagePicker สำหรับเรียกใช้งานกล้องหรือแกลเลอรี
  final ImagePicker _picker = ImagePicker();
  // ตัวแปรสถานะเพื่อแสดง loading indicator ขณะกำลังประมวลผล
  bool _isLoading = false;

  // ฟังก์ชันสำหรับขอสิทธิ์การใช้งานกล้อง
  Future<bool> _requestPermission() async {
    // ตรวจสอบสถานะของสิทธิ์การเข้าถึงกล้อง
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      // ถ้ายังไม่ได้รับอนุญาต ให้ทำการขอสิทธิ์
      status = await Permission.camera.request();
    }
    // คืนค่า true ถ้าได้รับอนุญาต
    return status.isGranted;
  }

  // ฟังก์ชันสำหรับถ่ายภาพ
  Future<void> _getImage() async {
    try {
      // เริ่มแสดง loading
      setState(() {
        _isLoading = true;
      });

      // ขอสิทธิ์การใช้งานกล้องก่อน
      bool hasPermission = await _requestPermission();
      if (!hasPermission) {
        // ถ้าไม่ได้รับสิทธิ์ ให้แสดงข้อความแจ้งเตือน
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาอนุญาตการเข้าถึงกล้อง')),
          );
        }
        return;
      }

      // เรียกใช้งานกล้องเพื่อถ่ายภาพ
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera, // กำหนดให้ใช้กล้อง
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80, // ลดคุณภาพเพื่อลดขนาดไฟล์
      );

      // ถ้าผู้ใช้ถ่ายภาพสำเร็จ (ไม่ได้กดยกเลิก)
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path); // แปลง XFile เป็น File แล้วเก็บในตัวแปร _image
        });
      }
    } catch (e) {
      // จัดการข้อผิดพลาดที่อาจเกิดขึ้น
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
        );
      }
    } finally {
      // ไม่ว่าจะสำเร็จหรือล้มเหลว ให้หยุดแสดง loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การถ่ายภาพจากกล้อง'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              // ตรวจสอบว่ามีรูปภาพหรือไม่
              child: _image == null
              // ถ้าไม่มี ให้แสดง placeholder
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('ไม่มีรูปภาพ', style: TextStyle(color: Colors.grey)),
                ],
              )
              // ถ้ามี ให้แสดงรูปภาพ
                  : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                  width: 300,
                  height: 300,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ตรวจสอบสถานะ loading
            _isLoading
                ? const CircularProgressIndicator() // ถ้ากำลังโหลด ให้แสดงวงกลมหมุน
                : ElevatedButton.icon( // ถ้าไม่ได้โหลด ให้แสดงปุ่ม
              onPressed: _getImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('ถ่ายภาพ'),
            ),
          ],
        ),
      ),
    );
  }
}