import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MultiImagePickerPage extends StatefulWidget {
  const MultiImagePickerPage({super.key});

  @override
  State<MultiImagePickerPage> createState() => _MultiImagePickerPageState();
}

class _MultiImagePickerPageState extends State<MultiImagePickerPage> {
  // เปลี่ยนจาก File? เป็น List<XFile> เพื่อเก็บรูปภาพหลายรูป
  List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // ฟังก์ชันสำหรับเลือกรูปภาพหลายรูป
  Future<void> _pickMultipleImages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // ใช้เมธอด pickMultiImage() เพื่อเลือกหลายรูป
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      // อัปเดต state ด้วยรายการรูปภาพที่เลือก
      setState(() {
        _images = pickedFiles;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
        );
      }
    } finally {
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
        title: const Text('เลือกรูปภาพหลายรูป'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _pickMultipleImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('เลือกรูปภาพ'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          // ใช้ Expanded และ GridView.builder เพื่อแสดงผลรูปภาพที่เลือก
          Expanded(
            child: _images.isEmpty
                ? const Center(
              child: Text('ยังไม่ได้เลือกรูปภาพ'),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // แสดง 3 รูปต่อแถว
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                // แสดงรูปภาพแต่ละรูปใน Card
                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 4.0,
                  child: Image.file(
                    File(_images[index].path),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}