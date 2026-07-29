import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime_v2/onnxruntime_v2.dart';

class RppgService {
  OrtSession? _session;

  /// Initialize ONNX Runtime and load the model from Flutter assets
  Future<void> initModel() async {
    // 1. Initialize global ONNX environment
    OrtEnv.instance.init();

    // 2. Set execution options
    final sessionOptions = OrtSessionOptions();
    sessionOptions.appendDefaultProviders();

    // 3. Load the model bytes directly from pubspec assets
    const assetPath = 'assets/models/efficientphys.onnx';
    final rawAssetFile = await rootBundle.load(assetPath);
    final bytes = rawAssetFile.buffer.asUint8List();

    // 4. Create inference session
    _session = OrtSession.fromBuffer(bytes, sessionOptions);
    debugPrint('ONNX Model loaded successfully!');
  }

  /// Run face scan inference on a 30-frame video tensor buffer
  Future<List<double>?> predictPulse(List<double> frameData) async {
    if (_session == null) return null;

    // Expected Shape: [Batch: 1, Channels: 3, Frames: 30, Height: 72, Width: 72]
    final shape = [1, 3, 30, 72, 72];
    final inputTensor = OrtValueTensor.createTensorWithDataList(frameData, shape);
    final inputs = {'video_frames': inputTensor};

    final runOptions = OrtRunOptions();
    final outputs = await _session?.runAsync(runOptions, inputs);

    // Clean up input allocations
    inputTensor.release();
    runOptions.release();

    if (outputs != null && outputs.isNotEmpty) {
      // Access output tensor raw data list safely
      final rawOutput = outputs[0]?.value;
      List<double>? bvpSignal;

      if (rawOutput is List) {
        bvpSignal = rawOutput.cast<double>();
      }

      // Replaced .forEach() with a standard for-in loop
      for (final output in outputs) {
        output?.release();
      }

      return bvpSignal;
    }

    return null;
  }

  void dispose() {
    _session?.release();
    OrtEnv.instance.release();
  }
}