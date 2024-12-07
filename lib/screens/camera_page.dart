import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';

class CameraPage extends StatefulWidget {
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

  Map<String, String> kapampanganToEnglish = {};
  Map<String, String> englishToKapampangan = {};
  Map<String, String> kapampanganToFilipino = {};
  Map<String, String> filipinoToKapampangan = {};

  @override
  void initState() {
    super.initState();
    initializeCamera();
    textRecognizer = GoogleMlKit.vision.textRecognizer();
    loadTranslationData();
  }

  // Load translation data from JSON
  Future<void> loadTranslationData() async {
    try {
      String data = await rootBundle.loadString('assets/kapampangan_table_kapampangan.json');
      final jsonResult = json.decode(data);
      for (var item in jsonResult['data']) {
        kapampanganToEnglish[item['kapampangan'].toLowerCase()] = item['english'];
        englishToKapampangan[item['english'].toLowerCase()] = item['kapampangan'];
        kapampanganToFilipino[item['kapampangan'].toLowerCase()] = item['filipino'];
        filipinoToKapampangan[item['filipino'].toLowerCase()] = item['kapampangan'];
      }
    } catch (e) {
      print('Error loading translation data: $e');
    }
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

      if (_translatedText != 'No translation found' && _translatedText.isNotEmpty) {
        HistoryItem historyItem = HistoryItem(
          action: 'Camera Scan',
          inputText: _extractedText,
          outputText: _translatedText,
          sourceLanguage: fromLanguage,
          targetLanguage: toLanguage,
          timestamp: DateTime.now(),
        );
        HistoryService().saveHistory(historyItem);
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

        if (_translatedText != 'No translation found' && _translatedText.isNotEmpty) {
          HistoryItem historyItem = HistoryItem(
            action: 'Image Gallery Scan',
            inputText: _extractedText,
            outputText: _translatedText,
            sourceLanguage: fromLanguage,
            targetLanguage: toLanguage,
            timestamp: DateTime.now(),
          );
          HistoryService().saveHistory(historyItem);
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
    String translation = '';
    inputText = inputText.toLowerCase().trim();

    // Try phrase-based translation first
    if (_checkLanguageAlignment(inputText)) {
      if (fromLanguage == 'Kapampangan') {
        translation = toLanguage == 'English'
            ? kapampanganToEnglish[inputText] ?? ''
            : kapampanganToFilipino[inputText] ?? '';
      } else if (fromLanguage == 'English') {
        translation = toLanguage == 'Kapampangan'
            ? englishToKapampangan[inputText] ?? ''
            : '';
      } else if (fromLanguage == 'Filipino') {
        translation = filipinoToKapampangan[inputText] ?? '';
      }
    }

    // Fallback to word-by-word translation if phrase translation fails
    if (translation.isEmpty) {
      translation = _translateWordByWord(inputText);
    }

    setState(() {
      _translatedText = translation.isNotEmpty ? translation : 'No translation found';
      _isTranslating = false;
    });
  }

  String _translateWordByWord(String sentence) {
    List<String> words = sentence.split(RegExp(r'\s+')); // Split the text into words
    List<String> translatedWords = [];

    bool allWordsNotFound = true;

    for (var word in words) {
      String translatedWord = _getTranslationForWord(word);
      if (translatedWord != 'No translation found') {
        translatedWords.add(translatedWord);
        allWordsNotFound = false;
      }
    }

    // If all words are not found, return a single "No translation found"
    if (allWordsNotFound) {
      return 'No translation found';
    }

    // Combine words back into a sentence if at least one word is translated
    return translatedWords.join(' ');
  }

  String _getTranslationForWord(String word) {
    word = word.toLowerCase();
    if (fromLanguage == 'English' && toLanguage == 'Kapampangan') {
      return englishToKapampangan[word] ?? 'No translation found';
    } else if (fromLanguage == 'Kapampangan' && toLanguage == 'English') {
      return kapampanganToEnglish[word] ?? 'No translation found';
    } else if (fromLanguage == 'Filipino' && toLanguage == 'Kapampangan') {
      return filipinoToKapampangan[word] ?? 'No translation found';
    } else if (fromLanguage == 'Kapampangan' && toLanguage == 'Filipino') {
      return kapampanganToFilipino[word] ?? 'No translation found';
    }
    return 'No translation found';
  }

  bool _checkLanguageAlignment(String inputText) {
    inputText = inputText.trim().toLowerCase();
    if (fromLanguage == 'English' && englishToKapampangan.containsKey(inputText)) {
      return true;
    } else if (fromLanguage == 'Kapampangan' && (kapampanganToEnglish.containsKey(inputText) || kapampanganToFilipino.containsKey(inputText))) {
      return true;
    } else if (fromLanguage == 'Filipino' && filipinoToKapampangan.containsKey(inputText)) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    textRecognizer.close();
    super.dispose();
  }

  List<String> _getToLanguageOptions() {
    if (fromLanguage == 'English' || fromLanguage == 'Filipino') {
      return ['Kapampangan'];
    } else if (fromLanguage == 'Kapampangan') {
      return ['English', 'Filipino'];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFF3F51B5),
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Camera Translation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLanguageDropdown(fromLanguage, '', (newValue) {
                    setState(() {
                      fromLanguage = newValue!;
                      _extractedText = 'No text recognized';
                      _translatedText = '';
                      toLanguage = _getToLanguageOptions().first;
                    });
                  }, ['English', 'Kapampangan', 'Filipino']),
                  IconButton(
                    icon: Icon(Icons.swap_horiz, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        String tempLanguage = fromLanguage;
                        fromLanguage = toLanguage;
                        toLanguage = tempLanguage;
                        _extractedText = 'No text recognized';
                        _translatedText = '';
                      });
                    },
                  ),
                  _buildLanguageDropdown(toLanguage, '', (newValue) {
                    setState(() {
                      toLanguage = newValue!;
                    });
                  }, _getToLanguageOptions()),
                ],
              ),
            ),
            if (_isCameraInitialized)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CameraPreview(_cameraController!),
                ),
              )
            else
              Center(
                child: Text(
                  'Initializing Camera...',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ),
            SizedBox(height: 20),
            _buildTextCard('Recognized Text:', _extractedText),
            SizedBox(height: 10),
            _buildTextCard('Translated Text:', _translatedText),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _isTranslating ? null : _captureAndRecognizeText,
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _isTranslating ? null : _chooseFromGallery,
                  backgroundColor: Colors.pinkAccent,
                  child: Icon(Icons.photo, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(String currentValue, String label, ValueChanged<String?> onChanged, List<String> options) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: currentValue,
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextCard(String title, String content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
            SizedBox(height: 8),
            Text(content, style: TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
