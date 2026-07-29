import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fftea/fftea.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  
  // 1. Configure ML Kit Face Detector with high accuracy mode
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: false,
    ),
  );

  final List<double> _greenSignalBuffer = [];
  bool _isProcessingFrame = false;
  Rect? _faceBoundingBox;
  double _progress = 0.0;
  
  // Target sample count (e.g., 300 frames ≈ 10 seconds at 30 fps)
  static const int _requiredSamples = 300;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    // Start streaming continuous frames
    _cameraController!.startImageStream((CameraImage image) {
      if (!_isProcessingFrame && _greenSignalBuffer.length < _requiredSamples) {
        _isProcessingFrame = true;
        _processFrame(image);
      }
    });

    if (mounted) setState(() {});
  }

  // --- Step A: Process Live Frame & Detect ROI ---
  Future<void> _processFrame(CameraImage image) async {
    try {
      // 1. Convert CameraImage format for ML Kit
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final InputImageRotation imageRotation = InputImageRotation.rotation270deg; 
      final InputImageFormat inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      // 2. Detect face location
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        _faceBoundingBox = faces.first.boundingBox;

        // 3. Extract average green intensity inside cheek/forehead ROI
        double greenAvg = _extractRoiGreenValue(image, _faceBoundingBox!);
        _greenSignalBuffer.add(greenAvg);

        setState(() {
          _progress = _greenSignalBuffer.length / _requiredSamples;
        });

        // 4. Run signal processing when buffer is full
        if (_greenSignalBuffer.length >= _requiredSamples) {
          _cameraController?.stopImageStream();
          int finalBpm = _processRppgSignal(_greenSignalBuffer);
          await _onScanComplete(finalBpm);
        }
      }
    } catch (e) {
      debugPrint('Error processing frame: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  // --- Step B: Crop Face ROI and Calculate Green Channel Mean ---
  double _extractRoiGreenValue(CameraImage image, Rect boundingBox) {
    final Plane yPlane = image.planes[0]; // Luminance / Green approximation
    
    // Crop specifically to center of the face (cheek region)
    int roiLeft = (boundingBox.left + boundingBox.width * 0.25).clamp(0, image.width.toDouble()).toInt();
    int roiRight = (boundingBox.right - boundingBox.width * 0.25).clamp(0, image.width.toDouble()).toInt();
    int roiTop = (boundingBox.top + boundingBox.height * 0.3).clamp(0, image.height.toDouble()).toInt();
    int roiBottom = (boundingBox.bottom - boundingBox.height * 0.3).clamp(0, image.height.toDouble()).toInt();

    double totalGreen = 0;
    int pixelCount = 0;

    for (int y = roiTop; y < roiBottom; y += 2) {
      for (int x = roiLeft; x < roiRight; x += 2) {
        int index = y * yPlane.bytesPerRow + x;
        if (index < yPlane.bytes.length) {
          totalGreen += yPlane.bytes[index];
          pixelCount++;
        }
      }
    }

    return pixelCount > 0 ? totalGreen / pixelCount : 0.0;
  }

  // --- Step C: Apply Bandpass Filtering & Fast Fourier Transform (FFT) ---
  int _processRppgSignal(List<double> rawSignal) {
    // 1. Mean-center the signal (subtract DC offset)
    double mean = rawSignal.reduce((a, b) => a + b) / rawSignal.length;
    List<double> centeredSignal = rawSignal.map((val) => val - mean).toList();

    // 2. Pad signal to nearest power of 2 for FFT (e.g., 512)
    int fftSize = 512;
    List<double> paddedSignal = List.filled(fftSize, 0.0);
    for (int i = 0; i < centeredSignal.length; i++) {
      paddedSignal[i] = centeredSignal[i];
    }

    // 3. Execute FFT
    final fft = FFT(fftSize);
    final freqSpectrum = fft.realFft(paddedSignal);

    // 4. Filter frequency range (0.75 Hz to 3.0 Hz corresponds to 45 BPM – 180 BPM)
    double frameRate = 30.0; // Approx FPS
    double maxMagnitude = -1.0;
    double peakFrequencyHz = 1.2; // Fallback (~72 BPM)

    for (int i = 0; i < freqSpectrum.length; i++) {
      double freqHz = (i * frameRate) / fftSize;

      // Keep only biological human heart rate frequency bounds
      if (freqHz >= 0.75 && freqHz <= 3.0) {
        // Compute Euclidean distance/magnitude: sqrt(real^2 + imag^2)
        final complexVal = freqSpectrum[i];
        double magnitude = sqrt(complexVal.x * complexVal.x + complexVal.y * complexVal.y);
        if (magnitude > maxMagnitude) {
          maxMagnitude = magnitude;
          peakFrequencyHz = freqHz;
        }
      }
    }

    // Convert peak frequency in Hz to Beats Per Minute (BPM)
    int calculatedBpm = (peakFrequencyHz * 60).round();
    return calculatedBpm.clamp(50, 160); // Ensure output stays in realistic bounds
  }

  // --- Step D: Store Calculated Result to Local Disk ---
  Future<void> _onScanComplete(int bpmResult) async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final timeString = "Today, ${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    await prefs.setInt('last_bpm', bpmResult);
    await prefs.setString('last_scan_time', timeString);

    if (mounted) {
      Navigator.pop(context); // Navigates back to update HomeScreen
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Live rPPG Face Scan'),
      ),
      body: Stack(
        children: [
          // Live Camera Stream
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // Scan Overlay Indicator
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _faceBoundingBox != null ? 'Detecting Pulse...' : 'Align face in camera view',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white10,
                    color: const Color(0xFF2DD4BF),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_progress * 100).toInt()}% Complete',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}