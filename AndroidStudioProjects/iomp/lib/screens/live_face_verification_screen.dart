import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../models/student.dart';

class LiveFaceVerificationScreen extends StatefulWidget {
  final Student student;

  const LiveFaceVerificationScreen({super.key, required this.student});

  @override
  State<LiveFaceVerificationScreen> createState() =>
      _LiveFaceVerificationScreenState();
}

class _LiveFaceVerificationScreenState
    extends State<LiveFaceVerificationScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isDetecting = false;
  bool _faceFound = false;

  @override
  void initState() {
    super.initState();
    _initializeFaceDetector();
    _initializeCamera();
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
    await _cameraController.initialize();

    _cameraController.startImageStream((CameraImage image) {
      if (_isDetecting || _faceFound) return;

      _isDetecting = true;

      _detectFaces(image).then((faces) {
        if (faces.isNotEmpty && !_faceFound) {
          setState(() {
            _faceFound = true;
          });
          if (mounted) {
            Navigator.pop(context, true); // Face verified successfully
          }
        }
      }).whenComplete(() => _isDetecting = false);
    });

    if (mounted) setState(() {});
  }

  Future<List<Face>> _detectFaces(CameraImage image) async {
    try {
      // Concatenate all planes into a single byte array (NV21 format)
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final camera = _cameraController.description;
      final imageRotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      ) ?? InputImageRotation.rotation0deg;

      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw) ??
              InputImageFormat.nv21;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow, // only first plane needed
        ),
      );

      return await _faceDetector.processImage(inputImage);
    } catch (e) {
      debugPrint("Face detection error: $e");
      return [];
    }
  }


  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Face Verification")),
      body: _cameraController.value.isInitialized
          ? CameraPreview(_cameraController)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
