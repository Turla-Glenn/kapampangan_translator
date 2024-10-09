import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

class MicrophonePage extends StatefulWidget {
  final Map<String, String> kapampanganToEnglish;
  final Map<String, String> englishToKapampangan;

  MicrophonePage({
    required this.kapampanganToEnglish,
    required this.englishToKapampangan,
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
  String targetLanguage = 'Kapampangan';

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
    String translation;
    inputText = inputText.toLowerCase().trim();

    if (inputText.isNotEmpty) {
      if (_isLanguageEnglish(inputText)) {
        setState(() {
          detectedLanguage = 'English';
          targetLanguage = 'Kapampangan';
        });
        translation = widget.englishToKapampangan[inputText] ?? 'No translation found';
      } else {
        setState(() {
          detectedLanguage = 'Kapampangan';
          targetLanguage = 'English';
        });
        translation = widget.kapampanganToEnglish[inputText] ?? 'No translation found';
      }

      setState(() {
        _translatedText = translation;
      });
    } else {
      setState(() {
        _translatedText = 'Please speak something to translate';
      });
    }
  }

  bool _isLanguageEnglish(String text) {
    // Simple language check based on known words.
    return widget.englishToKapampangan.containsKey(text);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  detectedLanguage,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Icon(Icons.swap_horiz, color: Colors.black),
                SizedBox(width: 10),
                Text(
                  targetLanguage,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Recognized and Translated Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                SizedBox(height: 15),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _spokenText = '';
                        _translatedText = '';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // Display the translation
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
