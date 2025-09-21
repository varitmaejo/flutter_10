import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  File? _video;
  VideoPlayerController? _controller;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<bool> _requestPermission() async {
    var cameraStatus = await Permission.camera.status;
    var micStatus = await Permission.microphone.status;

    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
    }
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  Future<void> _pickVideo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      bool hasPermission = await _requestPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาอนุญาตการเข้าถึงกล้องและไมโครโฟน')),
          );
        }
        return;
      }

      final XFile? pickedFile = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );

      if (pickedFile != null) {
        _video = File(pickedFile.path);
        await _controller?.dispose();
        _controller = VideoPlayerController.file(_video!)
          ..initialize().then((_) {
            setState(() {});
            _controller!.play();
          });
      }
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
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การถ่ายวิดีโอจากกล้อง'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 300,
              height: 300, // ปรับความสูงให้เหมาะสมกับวิดีโอ
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
              child: _controller == null
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('ไม่มีวิดีโอ', style: TextStyle(color: Colors.grey)),
                ],
              )
                  : _controller!.value.isInitialized
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
                  : const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('ถ่ายวิดีโอ'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  if (_controller != null && _controller!.value.isInitialized) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () => _controller!.play(),
                          icon: const Icon(Icons.play_arrow),
                          iconSize: 30,
                        ),
                        IconButton(
                          onPressed: () => _controller!.pause(),
                          icon: const Icon(Icons.pause),
                          iconSize: 30,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}