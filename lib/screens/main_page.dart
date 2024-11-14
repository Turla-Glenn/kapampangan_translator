import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'camera_page.dart';
import 'microphone_page.dart';
import '../widgets/app_drawer.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';

class MainPage extends StatefulWidget {
  final double titleVerticalOffset;
  final double titleHorizontalOffset;
  final double subtitleHorizontalOffset;

  MainPage({
    this.titleVerticalOffset = 5.0,
    this.titleHorizontalOffset = 25.0,
    this.subtitleHorizontalOffset = 40.0,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<String> languages = ['Detect language', 'English', 'Kapampangan', 'Filipino'];
  String fromLanguage = 'Detect language';
  String toLanguage = 'Kapampangan';
  TextEditingController inputController = TextEditingController();
  String translatedText = "";

  Map<String, String> kapampanganToEnglish = {};
  Map<String, String> englishToKapampangan = {};
  Map<String, String> kapampanganToFilipino = {};
  Map<String, String> filipinoToKapampangan = {};
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    loadTranslationData();
  }

  Future<void> loadTranslationData() async {
    String data = await rootBundle.loadString('assets/kapampangan_table_kapampangan.json');
    final jsonResult = json.decode(data);

    for (var item in jsonResult['data']) {
      kapampanganToEnglish[item['kapampangan'].toLowerCase()] = item['english'];
      englishToKapampangan[item['english'].toLowerCase()] = item['kapampangan'];
      kapampanganToFilipino[item['kapampangan'].toLowerCase()] = item['filipino'];
      filipinoToKapampangan[item['filipino'].toLowerCase()] = item['kapampangan'];
    }
  }

  void detectLanguageAndTranslate() {
    String inputText = inputController.text.trim().toLowerCase();

    // Reset the translated text before processing
    setState(() {
      translatedText = '';
    });

    if (inputText.isNotEmpty) {
      setState(() {
        if (fromLanguage == 'Detect language') {
          // Detect the language and set valid translation pairs
          if (englishToKapampangan.containsKey(inputText)) {
            fromLanguage = 'English';
            toLanguage = 'Kapampangan'; // Only show English to Kapampangan
          } else if (kapampanganToEnglish.containsKey(inputText)) {
            fromLanguage = 'Kapampangan';
            toLanguage = 'English'; // Default to Kapampangan to English
          } else if (filipinoToKapampangan.containsKey(inputText)) {
            fromLanguage = 'Filipino';
            toLanguage = 'Kapampangan'; // Only show Filipino to Kapampangan
          }
          translatedText = getTranslation(inputText);
        } else {
          // Use selected languages
          translatedText = getTranslation(inputText);
        }
      });

      // Save the final translated text to history only if it's valid
      if (translatedText != 'No translation found' && translatedText.isNotEmpty) {
        HistoryItem historyItem = HistoryItem(
          action: 'Text Translation',
          inputText: inputText,  // Save only the original input
          outputText: translatedText,  // Save only the final translated text
          sourceLanguage: fromLanguage,
          targetLanguage: toLanguage,
          timestamp: DateTime.now(),
        );

        HistoryService().saveHistory(historyItem);  // Save the translated history
      }
    } else {
      setState(() {
        translatedText = ''; // Clear any previously shown translation when input is empty
      });
    }
  }

  String getTranslation(String inputText) {
    if (fromLanguage == 'English' && toLanguage == 'Kapampangan') {
      return englishToKapampangan[inputText] ?? 'No translation found';
    } else if (fromLanguage == 'Kapampangan' && toLanguage == 'English') {
      return kapampanganToEnglish[inputText] ?? 'No translation found';
    } else if (fromLanguage == 'Filipino' && toLanguage == 'Kapampangan') {
      return filipinoToKapampangan[inputText] ?? 'No translation found';
    } else if (fromLanguage == 'Kapampangan' && toLanguage == 'Filipino') {
      return kapampanganToFilipino[inputText] ?? 'No translation found';
    } else {
      return 'No translation found';
    }
  }

  List<String> getAvailableTranslations() {
    // Return only valid options for `toLanguage` based on `fromLanguage`
    if (fromLanguage == 'English') {
      return ['Kapampangan'];
    } else if (fromLanguage == 'Kapampangan') {
      return ['English', 'Filipino'];
    } else if (fromLanguage == 'Filipino') {
      return ['Kapampangan'];
    } else {
      // Default case when fromLanguage is "Detect language"
      return languages.where((lang) => lang != 'Detect language').toList();
    }
  }

  void updateToLanguageOptions() {
    List<String> validTranslations = getAvailableTranslations();
    if (!validTranslations.contains(toLanguage)) {
      // If current `toLanguage` is not in valid options, set to first valid option
      setState(() {
        toLanguage = validTranslations.first;
      });
    }
  }

  Future<void> speakText(String text) async {
    await flutterTts.setLanguage(fromLanguage == 'Kapampangan' ? 'en' : 'en');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    // Ensure toLanguage is valid for the current fromLanguage
    updateToLanguageOptions();

    return Scaffold(
      backgroundColor: Color(0xFFEDEAFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: Offset(widget.titleHorizontalOffset, widget.titleVerticalOffset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kapampangan',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'Cursive',
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Transform.translate(
                  offset: Offset(widget.subtitleHorizontalOffset, 0),
                  child: Text(
                    'Translator',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Cursive',
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Scaffold.of(context).openDrawer();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: fromLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        fromLanguage = newValue!;
                        // Clear the input field and reset the translation when language changes
                        inputController.clear();
                        translatedText = '';
                        updateToLanguageOptions();
                      });
                    },
                    items: languages.map<DropdownMenuItem<String>>((String value) {
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
                        // Swap languages and adjust `toLanguage` options based on the new `fromLanguage`
                        String tempLanguage = fromLanguage;
                        fromLanguage = toLanguage;
                        toLanguage = tempLanguage;
                        inputController.clear();  // Reset the input field
                        translatedText = '';  // Reset the translated text
                        updateToLanguageOptions();
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
                    items: getAvailableTranslations().map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: inputController,
                          maxLines: null,
                          onChanged: (value) {
                            detectLanguageAndTranslate();
                          },
                          decoration: InputDecoration(
                            hintText: "Enter text to detect language and translate",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.volume_up, color: Colors.grey),
                            onPressed: () {
                              speakText(inputController.text);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.camera_alt, color: Colors.grey),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CameraPage(
                                    kapampanganToEnglish: kapampanganToEnglish,
                                    englishToKapampangan: englishToKapampangan,
                                    kapampanganToFilipino: kapampanganToFilipino,
                                    filipinoToKapampangan: filipinoToKapampangan,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.mic, color: Colors.grey),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MicrophonePage(
                                    kapampanganToEnglish: kapampanganToEnglish,
                                    englishToKapampangan: englishToKapampangan,
                                    kapampanganToFilipino: kapampanganToFilipino,
                                    filipinoToKapampangan: filipinoToKapampangan,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.volume_up, color: Colors.grey),
                          onPressed: () {
                            speakText(translatedText);
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        translatedText.isNotEmpty ? translatedText : "Translation will appear here",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
