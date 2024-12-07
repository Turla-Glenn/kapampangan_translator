import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/history_service.dart';
import '../models/history_item.dart';
import 'package:flutter/services.dart' show rootBundle;

class MicrophonePage extends StatefulWidget {
  @override
  _MicrophonePageState createState() => _MicrophonePageState();
}

class _MicrophonePageState extends State<MicrophonePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = 'Tap the mic to start listening';
  String _translatedText = '';
  String detectedLanguage = 'Detect language';

  // Default languages
  String fromLanguage = 'English';
  String targetLanguage = 'Kapampangan';

  // Translation maps
  Map<String, String> kapampanganToEnglish = {};
  Map<String, String> englishToKapampangan = {};
  Map<String, String> kapampanganToFilipino = {};
  Map<String, String> filipinoToKapampangan = {};

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
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

  // Start listening for speech
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _spokenText = val.recognizedWords;
          _translateSpokenText(_spokenText);
        }),
      );
    } else {
      setState(() => _isListening = false);
    }
  }

  // Stop listening
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // Translate the recognized text
  void _translateSpokenText(String inputText) {
    inputText = inputText.trim().toLowerCase();

    if (inputText.isNotEmpty) {
      // First check for phrase translation
      String translated = _translatePhrase(inputText);

      // If no translation found for phrase, fallback to word-by-word translation
      if (translated == 'No translation found') {
        translated = _translateWordByWord(inputText);
      }

      // Show translated text or "No translation found"
      _translatedText = translated != '' ? translated : 'No translation found';
    } else {
      _translatedText = 'Please say something to translate.';
    }

    setState(() {});

    // Save to history
    HistoryItem historyItem = HistoryItem(
      action: 'Speech Recognition',
      inputText: inputText,
      outputText: _translatedText,
      sourceLanguage: fromLanguage,
      targetLanguage: targetLanguage,
      timestamp: DateTime.now(),
    );

    HistoryService().saveHistory(historyItem);
  }

  // Translate a phrase if found
  String _translatePhrase(String sentence) {
    if (fromLanguage == 'Kapampangan') {
      if (targetLanguage == 'English' && kapampanganToEnglish.containsKey(sentence)) {
        return kapampanganToEnglish[sentence]!;
      } else if (targetLanguage == 'Filipino' && kapampanganToFilipino.containsKey(sentence)) {
        return kapampanganToFilipino[sentence]!;
      }
    } else if (fromLanguage == 'English') {
      if (targetLanguage == 'Kapampangan' && englishToKapampangan.containsKey(sentence)) {
        return englishToKapampangan[sentence]!;
      }
    } else if (fromLanguage == 'Filipino') {
      if (targetLanguage == 'Kapampangan' && filipinoToKapampangan.containsKey(sentence)) {
        return filipinoToKapampangan[sentence]!;
      }
    }
    return 'No translation found';  // No phrase match found
  }

  // Translate word-by-word if phrase not found
  String _translateWordByWord(String sentence) {
    List<String> words = sentence.split(' ');
    List<String> translatedWords = [];

    for (var word in words) {
      String normalizedWord = _normalizeText(word);
      String wordTranslation = _getTranslationForWord(normalizedWord);

      // If translation is found, add it, else return "No translation found"
      if (wordTranslation != 'No translation found') {
        translatedWords.add(wordTranslation);
      } else {
        return 'No translation found';  // Return immediately if any word isn't found
      }
    }

    return translatedWords.join(' ');
  }

  // Helper method to translate individual words
  String _getTranslationForWord(String word) {
    word = word.toLowerCase();
    if (fromLanguage == 'English' && targetLanguage == 'Kapampangan') {
      return englishToKapampangan[word] ?? 'No translation found';
    } else if (fromLanguage == 'Kapampangan' && targetLanguage == 'English') {
      return kapampanganToEnglish[word] ?? 'No translation found';
    } else if (fromLanguage == 'Filipino' && targetLanguage == 'Kapampangan') {
      return filipinoToKapampangan[word] ?? 'No translation found';
    } else if (fromLanguage == 'Kapampangan' && targetLanguage == 'Filipino') {
      return kapampanganToFilipino[word] ?? 'No translation found';
    }
    return 'No translation found';
  }

  // Normalize text for translation
  String _normalizeText(String word) {
    return word.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  }

  // Determine valid target languages based on the selected fromLanguage
  List<String> _getTargetLanguageOptions() {
    if (fromLanguage == 'English' || fromLanguage == 'Filipino') {
      return ['Kapampangan'];
    } else if (fromLanguage == 'Kapampangan') {
      return ['English', 'Filipino'];
    }
    return [];
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
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
        title: Text('Microphone Translation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Language Selection
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: fromLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        fromLanguage = newValue!;
                        _spokenText = 'Tap the mic to start listening';
                        _translatedText = '';
                        // Automatically set targetLanguage to the first valid option
                        targetLanguage = _getTargetLanguageOptions().first;
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
                        // Swap languages and reset texts
                        String tempLanguage = fromLanguage;
                        fromLanguage = targetLanguage;
                        targetLanguage = tempLanguage;
                        _spokenText = 'Tap the mic to start listening';
                        _translatedText = '';
                      });
                    },
                  ),
                  DropdownButton<String>(
                    value: targetLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        targetLanguage = newValue!;
                      });
                    },
                    items: _getTargetLanguageOptions().map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Spoken Text Display
            _buildTextCard('Recognized Text:', _spokenText),

            SizedBox(height: 10),

            // Translated Text Display
            _buildTextCard('Translated Text:', _translatedText),

            SizedBox(height: 20),

            // Microphone Toggle Switch
            SwitchListTile(
              title: Text(_isListening ? 'Microphone On' : 'Microphone Off'),
              value: _isListening,
              onChanged: (bool value) {
                if (value) {
                  _startListening();
                } else {
                  _stopListening();
                }
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.grey,
            ),
          ],
        ),
      ),
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
