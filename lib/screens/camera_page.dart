import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';

class CameraPage extends StatefulWidget {
  final Map<String, String> kapampanganToEnglish;
  final Map<String, String> englishToKapampangan;
  final Map<String, String> kapampanganToFilipino;
  final Map<String, String> filipinoToKapampangan;

  CameraPage({
    required this.kapampanganToEnglish,
    required this.englishToKapampangan,
    required this.kapampanganToFilipino,
    required this.filipinoToKapampangan,
  });

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String _extractedText = 'No text recognized';
  String _translatedText = '';
  late TextRecognizer textRecognizer;
  bool _isTranslating = false;

  String fromLanguage = 'English';
  String toLanguage = 'Kapampangan';

  @override
  void initState() {
    super.initState();
    initializeCamera();
    textRecognizer = GoogleMlKit.vision.textRecognizer();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      setState(() {
        _extractedText = 'No camera available';
      });
    }
  }

  Future<void> _captureAndRecognizeText() async {
    setState(() {
      _isTranslating = true;
    });

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text.isNotEmpty ? recognizedText.text : 'No text recognized';
        _translateCapturedText(_extractedText);
      });

      // Save the recognized text to history if it's valid
      if (_translatedText != 'No translation found' && _translatedText.isNotEmpty) {
        HistoryItem historyItem = HistoryItem(
          action: 'Camera Scan',
          inputText: _extractedText,
          outputText: _translatedText,
          sourceLanguage: fromLanguage,
          targetLanguage: toLanguage,
          timestamp: DateTime.now(),
        );
        HistoryService().saveHistory(historyItem);  // Save history
      }
    } catch (e) {
      setState(() {
        _extractedText = 'Error capturing image: $e';
        _translatedText = '';
        _isTranslating = false;
      });
    }
  }

  Future<void> _chooseFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        setState(() {
          _extractedText = recognizedText.text.isNotEmpty ? recognizedText.text : 'No text recognized';
          _translateCapturedText(_extractedText);
        });

        // Save the recognized text to history if it's valid
        if (_translatedText != 'No translation found' && _translatedText.isNotEmpty) {
          HistoryItem historyItem = HistoryItem(
            action: 'Image Gallery Scan',
            inputText: _extractedText,
            outputText: _translatedText,
            sourceLanguage: fromLanguage,
            targetLanguage: toLanguage,
            timestamp: DateTime.now(),
          );
          HistoryService().saveHistory(historyItem);  // Save history
        }
      } catch (e) {
        setState(() {
          _extractedText = 'Error processing image: $e';
          _translatedText = '';
        });
      }
    }
  }

  void _translateCapturedText(String inputText) {
    String translation;
    inputText = inputText.toLowerCase().trim();

    if (inputText.isNotEmpty) {
      if (fromLanguage == 'English' && toLanguage == 'Kapampangan') {
        translation = widget.englishToKapampangan[inputText] ?? 'No translation found';
      } else if (fromLanguage == 'Kapampangan' && toLanguage == 'English') {
        translation = widget.kapampanganToEnglish[inputText] ?? 'No translation found';
      } else if (fromLanguage == 'Filipino' && toLanguage == 'Kapampangan') {
        translation = widget.filipinoToKapampangan[inputText] ?? 'No translation found';
      } else if (fromLanguage == 'Kapampangan' && toLanguage == 'Filipino') {
        translation = widget.kapampanganToFilipino[inputText] ?? 'No translation found';
      } else {
        translation = 'No translation found';
      }

      setState(() {
        _translatedText = translation;
        _isTranslating = false;
      });
    } else {
      setState(() {
        _translatedText = 'Please enter some text to translate';
        _isTranslating = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDEAFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.purple[200]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Language selection dropdowns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  value: fromLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      fromLanguage = newValue!;
                      _extractedText = 'No text recognized';  // Reset recognized text
                      _translatedText = '';  // Reset translated text
                    });
                  },
                  items: ['English', 'Kapampangan', 'Filipino'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                IconButton(
                  icon: Icon(Icons.swap_horiz, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      // Swap languages
                      String tempLanguage = fromLanguage;
                      fromLanguage = toLanguage;
                      toLanguage = tempLanguage;
                      _extractedText = 'No text recognized';  // Reset recognized text
                      _translatedText = '';  // Reset translated text
                    });
                  },
                ),
                DropdownButton<String>(
                  value: toLanguage,
                  onChanged: (String? newValue) {
                    setState(() {
                      toLanguage = newValue!;
                    });
                  },
                  items: ['Kapampangan', 'Filipino', 'English'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Camera Preview
          if (_isCameraInitialized)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            Container(
              height: 300,
              color: Colors.black12,
              child: Center(
                child: Text(
                  'Initializing Camera...',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
            ),
          SizedBox(height: 20),

          // Display recognized text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recognized Text:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_extractedText, style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 15),
                Text(
                  'Translated Text:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_translatedText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Capture and select image buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _isTranslating ? null : _captureAndRecognizeText,
                  backgroundColor: Colors.pink,
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                ),
                SizedBox(width: 30),
                IconButton(
                  icon: Icon(Icons.photo, color: Colors.purple[200], size: 40),
                  onPressed: _chooseFromGallery,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
