import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class PhrasebookScreen extends StatefulWidget {
  @override
  _PhrasebookScreenState createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends State<PhrasebookScreen> {
  List<dynamic> _phrases = [];

  @override
  void initState() {
    super.initState();
    _loadPhrasebookData();
  }

  // Load JSON data from the assets
  Future<void> _loadPhrasebookData() async {
    final String response = await rootBundle.loadString('assets/kapampangan_sentences.json');
    final data = await json.decode(response);
    setState(() {
      _phrases = data['data'];  // Extract the data array from JSON
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phrasebook'),
      ),
      body: _phrases.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable(
            columnSpacing: 20,
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Kapampangan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'Filipino',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataColumn(
                label: Text(
                  'English',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
            rows: _phrases
                .map<DataRow>(
                  (phrase) => DataRow(
                cells: <DataCell>[
                  DataCell(Text(phrase['kapampangan'])),
                  DataCell(Text(phrase['filipino'])),
                  DataCell(Text(phrase['english'])),
                ],
              ),
            )
                .toList(),
          ),
        ),
      ),
    );
  }
}
