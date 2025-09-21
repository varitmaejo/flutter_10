import 'package:flutter/material.dart';
import 'package:flutter_10/pages/camera_page.dart';
import 'package:flutter_10/pages/gallery_page.dart';
import 'package:flutter_10/pages/qr_generator_page.dart';
import 'package:flutter_10/pages/scan_page.dart';
import 'package:flutter_10/pages/video_page.dart';
import 'package:flutter_10/pages/gallery_video_page.dart';
import 'package:flutter_10/pages/multi_image_picker_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เมนูหลัก'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [

          _buildMenuItem(
            context,
            icon: Icons.camera_alt,
            title: 'ถ่ายภาพ',
            subtitle: 'เปิดกล้องเพื่อถ่ายภาพนิ่ง',
            page: const CameraPage(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.photo_library,
            title: 'เลือกภาพจากแกลเลอรี',
            subtitle: 'เลือกภาพจากคลังรูปภาพ',
            page: const GalleryPage(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.videocam,
            title: 'ถ่ายวิดีโอ',
            subtitle: 'เปิดกล้องเพื่อบันทึกวิดีโอ',
            page: const VideoPage(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.video_library,
            title: 'เลือกวิดีโอจากแกลเลอรี',
            subtitle: 'เลือกวิดีโอจากคลังวิดีโอ',
            page: const GalleryVideoPage(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.qr_code_scanner,
            title: 'สแกน QR Code / Barcode',
            subtitle: 'สแกนรหัสด้วยกล้อง',
            page: const ScanPage(),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('ตัวอย่างประยุกต์', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),
          // (ใหม่) เพิ่มเมนูสำหรับตัวอย่างประยุกต์
          _buildMenuItem(
            context,
            icon: Icons.photo_album,
            title: 'เลือกรูปภาพหลายรูป',
            subtitle: 'เลือกรูปภาพหลายรูปจากแกลเลอรี',
            page: const MultiImagePickerPage(),
          ),
          _buildMenuItem(
            context,
            icon: Icons.qr_code_2,
            title: 'สร้าง QR Code',
            subtitle: 'สร้าง QR Code จากข้อความหรือลิงก์',
            page: const QrGeneratorPage(),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับสร้างรายการเมนูแต่ละอัน เพื่อลดการเขียนโค้ดซ้ำซ้อน
  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required Widget page}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // เมื่อแตะที่รายการ ให้เปลี่ยนหน้า (Navigate) ไปยังหน้าที่กำหนด
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }
}