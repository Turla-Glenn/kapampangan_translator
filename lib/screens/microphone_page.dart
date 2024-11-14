import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/history_service.dart';
import '../models/history_item.dart';

class MicrophonePage extends StatefulWidget {
  final Map<String, String> kapampanganToEnglish;
  final Map<String, String> englishToKapampangan;
  final Map<String, String> kapampanganToFilipino;
  final Map<String, String> filipinoToKapampangan;

  MicrophonePage({
    required this.kapampanganToEnglish,
    required this.englishToKapampangan,
    required this.kapampanganToFilipino,
    required this.filipinoToKapampangan,
  });

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
  String targetLanguage = 'Kapampangan';   // Target language
  String fromLanguage = 'English';          // From language (source language)

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

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

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _translateSpokenText(String inputText) {
    String translation = '';
    inputText = inputText.toLowerCase().trim();

    if (inputText.isNotEmpty) {
      // Handle translation logic for all language pairs
      if (fromLanguage == 'English' && targetLanguage == 'Kapampangan') {
        translation = widget.englishToKapampangan[inputText] ?? 'No translation found';
      } else if (fromLanguage == 'Kapampangan' && targetLanguage == 'English') {
        translation = widget.kapampanganToEnglish[inputText] ?? 'No translation found';
      } else if (fromLanguage == 'Filipino' && targetLanguage == 'Kapampangan') {
        translation = widget.filipinoToKapampangan[inputText] ?? 'No translation found';
      } else if (fromLanguage == 'Kapampangan' && targetLanguage == 'Filipino') {
        translation = widget.kapampanganToFilipino[inputText] ?? 'No translation found';
      }

      setState(() {
        _translatedText = translation;
      });

      // Save the recognized speech and translation to history
      HistoryItem historyItem = HistoryItem(
        action: 'Speech Recognition',
        inputText: inputText,
        outputText: _translatedText,
        sourceLanguage: fromLanguage,
        targetLanguage: targetLanguage,
        timestamp: DateTime.now(),
      );

      HistoryService().saveHistory(historyItem);  // Save history
    } else {
      setState(() {
        _translatedText = 'Please speak something to translate';
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Language Selection Dropdowns
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
                      // Reset the translated text when language is changed
                      _spokenText = 'Tap the mic to start listening';
                      _translatedText = '';
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
                      // Swap languages and reset text
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
          SizedBox(height: 20),

          // Spoken Text Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _spokenText,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Translated Text Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _translatedText.isNotEmpty ? _translatedText : "Translation will appear here",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Microphone Button
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: FloatingActionButton(
              backgroundColor: Colors.pink,
              onPressed: _isListening ? _stopListening : _startListening,
              child: Icon(_isListening ? Icons.mic : Icons.mic_off, color: Colors.white),
              tooltip: 'Start Speaking',
            ),
          ),
        ],
      ),
    );
  }
}
