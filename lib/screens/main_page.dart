import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'camera_page.dart';
import 'microphone_page.dart';
import '../widgets/app_drawer.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  final double titleVerticalOffset;
  final double titleHorizontalOffset;
  final double subtitleHorizontalOffset;

  MainPage({
    this.titleVerticalOffset = 5.0,
    this.titleHorizontalOffset = 75.0,
    this.subtitleHorizontalOffset = 40.0,
  });

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<String> languages = ['English', 'Kapampangan', 'Filipino'];
  String fromLanguage = 'Kapampangan'; // Default to Kapampangan
  String toLanguage = 'Kapampangan';
  TextEditingController inputController = TextEditingController();
  String translatedText = "";
  String originalInputText = ""; // Store the original Kapampangan input
  bool isTextInputted = false;

  List<String> suggestedWords = [];  // List to hold suggested words

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

  // Loading Translation Data
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

  String getTranslation(String inputText) {
    String normalizedInput = _normalizeInput(inputText);

    if (fromLanguage == 'English' && toLanguage == 'Kapampangan') {
      return englishToKapampangan[normalizedInput] ?? 'No translation found';
    } else if (fromLanguage == 'Kapampangan' && toLanguage == 'English') {
      return kapampanganToEnglish[normalizedInput] ?? 'No translation found';
    } else if (fromLanguage == 'Filipino' && toLanguage == 'Kapampangan') {
      return filipinoToKapampangan[normalizedInput] ?? 'No translation found';
    } else if (fromLanguage == 'Kapampangan' && toLanguage == 'Filipino') {
      return kapampanganToFilipino[normalizedInput] ?? 'No translation found';
    } else {
      return 'No translation found';
    }
  }

  List<String> getAvailableTranslations() {
    if (fromLanguage == 'English') {
      return ['Kapampangan'];
    } else if (fromLanguage == 'Kapampangan') {
      return ['English', 'Filipino'];
    } else if (fromLanguage == 'Filipino') {
      return ['Kapampangan'];
    } else {
      return languages;
    }
  }

  void updateToLanguageOptions() {
    List<String> validTranslations = getAvailableTranslations();
    if (!validTranslations.contains(toLanguage)) {
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

  // Normalize input by removing punctuation and converting to lowercase
  String _normalizeInput(String inputText) {
    String normalizedText = inputText.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').toLowerCase();
    return normalizedText;
  }

  void handleInputChange(String value) {
    setState(() {
      isTextInputted = value.isNotEmpty;
      if (value.isNotEmpty) {
        if (kapampanganToEnglish.containsKey(_normalizeInput(value))) {
          fromLanguage = 'Kapampangan';
        } else if (englishToKapampangan.containsKey(_normalizeInput(value))) {
          fromLanguage = 'English';
        } else if (filipinoToKapampangan.containsKey(_normalizeInput(value))) {
          fromLanguage = 'Filipino';
        }

        // Fetch word suggestions based on the input
        _fetchSuggestedWords(value);
      }

      if (value.isEmpty) {
        fromLanguage = 'Kapampangan'; // Default to Kapampangan
        translatedText = '';
        suggestedWords.clear(); // Clear suggestions
      }

      originalInputText = value;
    });
  }

  // Function to fetch suggested words based on the input
  void _fetchSuggestedWords(String input) {
    List<String> words = [];
    if (fromLanguage == 'Kapampangan') {
      words = kapampanganToEnglish.keys
          .where((word) => word.contains(input.toLowerCase()))
          .toList();
    } else if (fromLanguage == 'English') {
      words = englishToKapampangan.keys
          .where((word) => word.contains(input.toLowerCase()))
          .toList();
    } else if (fromLanguage == 'Filipino') {
      words = filipinoToKapampangan.keys
          .where((word) => word.contains(input.toLowerCase()))
          .toList();
    }

    setState(() {
      suggestedWords = words.take(5).toList(); // Limit suggestions to 5
    });
  }

  // This function will be triggered when switching languages
  void switchLanguages() {
    setState(() {
      String tempLanguage = fromLanguage;
      fromLanguage = toLanguage;
      toLanguage = tempLanguage;

      String tempText = inputController.text;
      inputController.text = translatedText;
      translatedText = getTranslation(tempText.trim().toLowerCase());
    });
  }

// Function to translate a sentence
  String translateSentence(String sentence) {
    // Normalize input and check for exact match in phrases
    String normalizedSentence = _normalizeInput(sentence);

    // Check if the input matches any of the suggested phrases
    if (kapampanganToEnglish.containsKey(normalizedSentence) ||
        englishToKapampangan.containsKey(normalizedSentence) ||
        kapampanganToFilipino.containsKey(normalizedSentence) ||
        filipinoToKapampangan.containsKey(normalizedSentence)) {
      return getTranslation(normalizedSentence); // Return phrase translation
    }

    // If no match is found, proceed to word-by-word translation
    List<String> words = sentence.split(RegExp(r'\s+'));
    List<String> translatedWords = [];

    bool hasValidTranslation = false;

    for (var word in words) {
      String normalizedWord = _normalizeInput(word);
      String translatedWord = getTranslation(normalizedWord);

      // Check if the word has a valid translation
      if (translatedWord != 'No translation found') {
        hasValidTranslation = true;
      }

      // Avoid appending multiple "No translation found" for untranslated words
      translatedWords.add(translatedWord == 'No translation found' ? '' : translatedWord);
    }

    // If no valid translations exist for the entire sentence
    if (!hasValidTranslation) {
      return 'No translation found';
    }

    // Join translated words while skipping empty translations
    return translatedWords.where((word) => word.isNotEmpty).join(' ');
  }


  @override
  Widget build(BuildContext context) {
    updateToLanguageOptions();

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        centerTitle: true, // Ensures the title is centered
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
                  'Ka Tag Lish',
                  style: GoogleFonts.molle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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
                        // Keep input text as it is, only change the translation
                        inputController.text = originalInputText;
                        translatedText = ''; // Clear translated text
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
                    onPressed: switchLanguages, // Swap languages
                  ),
                  DropdownButton<String>(
                    value: toLanguage,
                    onChanged: (String? newValue) {
                      setState(() {
                        toLanguage = newValue!;
                        // Keep input text as it is, only change the translation
                        inputController.text = originalInputText;
                        translatedText = ''; // Clear translated text
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: inputController,
                      maxLines: null,
                      onChanged: handleInputChange,
                      decoration: InputDecoration(
                        hintText: "Enter text to translate",
                        labelText: fromLanguage, // Show the input language here
                        border: InputBorder.none,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Display suggested words horizontally with horizontal scroll
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: suggestedWords.map((word) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  inputController.text = word; // Replace the input text with the suggested word
                                  suggestedWords.clear(); // Clear suggestions after selection
                                  isTextInputted = true; // Ensure the Translate button remains visible
                                });
                              },
                              child: Text(word),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              // Translate button - visible when text is inputted
              if (isTextInputted)
                ElevatedButton(
                  onPressed: () {
                    String inputText = inputController.text.trim().toLowerCase();
                    setState(() {
                      translatedText = translateSentence(inputText);
                    });

                    // Save translation to history if result is valid
                    if (translatedText.isNotEmpty && translatedText != 'No translation found') {
                      HistoryItem historyItem = HistoryItem(
                        action: 'Text Translation',
                        inputText: inputText,
                        outputText: translatedText,
                        sourceLanguage: fromLanguage,
                        targetLanguage: toLanguage,
                        timestamp: DateTime.now(),
                      );
                      HistoryService().saveHistory(historyItem);
                    }
                  },
                  child: Text("Translate"),
                ),
              SizedBox(height: 20),
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.volume_up, color: Colors.grey),
                                onPressed: () {
                                  speakText(translatedText); // Speak out the translated text
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.copy, color: Colors.grey),
                                onPressed: () {
                                  // Copy the translated text to clipboard
                                  Clipboard.setData(ClipboardData(text: translatedText)).then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Text copied to clipboard!')),
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 0),
                        Text(
                          translatedText.isNotEmpty ? translatedText : "Translation will appear here",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Translated from $fromLanguage to $toLanguage',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
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
