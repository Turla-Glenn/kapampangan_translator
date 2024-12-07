import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  List<dynamic> _dictionaryData = [];
  List<dynamic> _filteredDictionaryData = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDictionaryData();
  }

  // Load JSON data from the assets
  Future<void> _loadDictionaryData() async {
    final String response = await rootBundle.loadString('assets/kapampangan_words.json');
    final Map<String, dynamic> data = json.decode(response); // Decode as Map
    if (data.containsKey('data') && data['data'] is List) {
      setState(() {
        _dictionaryData = data['data']; // Access the 'data' key
        _filteredDictionaryData = _dictionaryData; // Initially show all data
      });
    } else {
      print('Error: JSON does not contain a valid "data" key.');
    }
  }

  // Filter the dictionary based on the search query
  void _filterDictionary(String query) {
    List<dynamic> filteredResults = _dictionaryData.where((entry) {
      return entry['kapampangan_word'].toString().toLowerCase().contains(query.toLowerCase()) ||
          entry['noun'].toString().toLowerCase().contains(query.toLowerCase()) ||
          entry['descriptive'].toString().toLowerCase().contains(query.toLowerCase()) ||
          entry['verb'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredDictionaryData = filteredResults;
    });
  }

  // Highlight the search term in the result
  Widget _highlightText(String text, String query) {
    if (query.isEmpty) {
      return Text(text);
    }
    List<TextSpan> spans = [];
    int start = 0;
    int index;
    text = text.toLowerCase();
    query = query.toLowerCase();

    // Find matches and split text accordingly
    while ((index = text.indexOf(query, start)) != -1) {
      spans.add(TextSpan(text: text.substring(start, index)));
      spans.add(TextSpan(text: text.substring(index, index + query.length), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)));
      start = index + query.length;
    }
    spans.add(TextSpan(text: text.substring(start)));

    return RichText(text: TextSpan(style: TextStyle(color: Colors.black), children: spans));
  }

  // Display non-empty fields
  Widget _displayField(String label, String value) {
    if (value.isEmpty) {
      return SizedBox.shrink(); // Do not show anything if value is empty
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kapampangan Dictionary'),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search TextField
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: TextField(
                onChanged: (text) => _filterDictionary(text),
                decoration: InputDecoration(
                  labelText: 'Search for words...',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Display filtered dictionary data
            Expanded(
              child: _filteredDictionaryData.isEmpty
                  ? Center(child: Text('No results found', style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : ListView.builder(
                itemCount: _filteredDictionaryData.length,
                itemBuilder: (context, index) {
                  var entry = _filteredDictionaryData[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: _highlightText(entry['kapampangan_word'], _searchQuery),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _displayField('Noun', entry['noun']),
                          _displayField('Descriptive', entry['descriptive']),
                          _displayField('Verb', entry['verb']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
