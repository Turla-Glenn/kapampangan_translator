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
    final String response = await rootBundle.loadString('assets/kapampangan_table_kapampangan.json');
    final data = await json.decode(response);
    setState(() {
      _dictionaryData = data['data'];
      _filteredDictionaryData = _dictionaryData;  // Initially show all data
    });
  }

  // Filter the dictionary based on the search query
  void _filterDictionary(String query) {
    List<dynamic> filteredResults = _dictionaryData.where((entry) {
      return entry['kapampangan'].toString().toLowerCase().contains(query.toLowerCase()) ||
          entry['filipino'].toString().toLowerCase().contains(query.toLowerCase()) ||
          entry['english'].toString().toLowerCase().contains(query.toLowerCase());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dictionary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search TextField
            TextField(
              onChanged: (text) => _filterDictionary(text),
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20),

            // Display filtered dictionary data
            Expanded(
              child: _filteredDictionaryData.isEmpty
                  ? Center(child: Text('No results found'))
                  : ListView.builder(
                itemCount: _filteredDictionaryData.length,
                itemBuilder: (context, index) {
                  var entry = _filteredDictionaryData[index];
                  return Card(
                    child: ListTile(
                      title: _highlightText(entry['kapampangan'], _searchQuery),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Filipino: ${entry['filipino']}'),
                          Text('English: ${entry['english']}'),
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
