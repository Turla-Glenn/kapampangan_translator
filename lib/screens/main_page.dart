import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'camera_page.dart';
import 'microphone_page.dart';
import '../widgets/app_drawer.dart'; // Import the drawer widget

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String fromLanguage = 'English';
  String toLanguage = 'Kapampangan';
  TextEditingController inputController = TextEditingController();
  String translatedText = "";

  Map<String, String> kapampanganToEnglish = {};
  Map<String, String> englishToKapampangan = {};
  FlutterTts flutterTts = FlutterTts(); // Initialize the FlutterTTS instance

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
    }
  }

  void switchLanguages() {
    setState(() {
      String temp = fromLanguage;
      fromLanguage = toLanguage;
      toLanguage = temp;
      inputController.clear();
      translatedText = "";
    });
  }

  void translateText() {
    String inputText = inputController.text.trim().toLowerCase();
    if (inputText.isNotEmpty) {
      setState(() {
        if (fromLanguage == 'Kapampangan') {
          translatedText = kapampanganToEnglish[inputText] ?? 'No translation found';
        } else if (fromLanguage == 'English') {
          translatedText = englishToKapampangan[inputText] ?? 'No translation found';
        }
      });
    } else {
      setState(() {
        translatedText = 'Please enter some text to translate';
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
    return Scaffold(
      backgroundColor: Color(0xFFEDEAFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90,
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(
                'Translator',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Cursive',
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: AppDrawer(), // Use the AppDrawer here
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Scaffold.of(context).openDrawer(); // Open the drawer on a right swipe
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
                  Text(
                    fromLanguage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.swap_horiz, color: Colors.black),
                    onPressed: switchLanguages,
                  ),
                  SizedBox(width: 10),
                  Text(
                    toLanguage,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                            translateText();
                          },
                          decoration: InputDecoration(
                            hintText: "Enter text in $fromLanguage",
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
