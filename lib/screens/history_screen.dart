import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _historyData = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    final String response = await rootBundle.loadString('assets/kapampangan_table_histories.json');
    final data = await json.decode(response);
    setState(() {
      _historyData = data['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: _historyData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _historyData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('From: ${_historyData[index]['from_text']}'),
            subtitle: Text('To: ${_historyData[index]['to_text']}'),
          );
        },
      ),
    );
  }
}
