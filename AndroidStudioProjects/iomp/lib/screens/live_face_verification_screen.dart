import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:camera/camera.dart';
import 'dart:convert';

import '../models/student.dart';

class LiveFaceVerificationScreen extends StatefulWidget {
  final Student student;

  const LiveFaceVerificationScreen({Key? key, required this.student})
      : super(key: key);

  @override
  _LiveFaceVerificationScreenState createState() =>
      _LiveFaceVerificationScreenState();
}

class _LiveFaceVerificationScreenState extends State<LiveFaceVerificationScreen> {
  CameraController? _cameraController;
  File? _capturedImage;
  bool _isUploading = false;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      await _cameraController?.initialize();
      setState(() {});
    } catch (e) {
      setState(() {
        _resultMessage = "Error initializing camera: $e";
      });
    }
  }

  Future<void> _captureAndVerify() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() {
        _resultMessage = "Camera not ready!";
      });
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      final imageFile = File(image.path);

      setState(() {
        _capturedImage = imageFile;
        _isUploading = true;
      });

      await _uploadImage(imageFile);
    } catch (e) {
      setState(() {
        _resultMessage = "Error capturing image: $e";
      });
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      final uri = Uri.parse('http://192.168.0.131:5001/verify');
      final request = http.MultipartRequest('POST', uri);

      request.fields['rollNumber'] = widget.student.rollNumber;

      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'liveImage',
          image.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(responseBody);

        if (jsonResponse['success'] == true) {
          // Verification success, update student's isVerified locally
          widget.student.isVerified = true;

          // Return true to previous screen to update UI
          if (!mounted) return;
          Navigator.pop(context, true);
        } else {
          setState(() {
            _resultMessage = 'Verification failed: ${jsonResponse['message']}';
          });
        }
      } else {
        setState(() {
          _resultMessage =
          'Verification failed with status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error during verification: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify ${widget.student.rollNumber}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_cameraController != null && _cameraController!.value.isInitialized)
              SizedBox(
                height: 300,
                child: CameraPreview(_cameraController!),
              ),
            const SizedBox(height: 20),
            if (_capturedImage != null)
              Column(
                children: [
                  const Text('Captured Image:', style: TextStyle(fontSize: 16)),
                  Image.file(
                    _capturedImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            if (_isUploading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            if (_resultMessage != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  _resultMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _captureAndVerify,
              child: const Text('Capture & Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
