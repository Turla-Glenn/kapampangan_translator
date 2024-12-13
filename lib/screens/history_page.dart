import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';
import 'package:flutter/services.dart'; // For clipboard operations

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<HistoryItem>> _history;

  @override
  void initState() {
    super.initState();
    _history = fetchSortedHistory();
  }

  // Fetch history sorted in reverse chronological order
  Future<List<HistoryItem>> fetchSortedHistory() async {
    List<HistoryItem> history = await HistoryService().getHistory();
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by timestamp descending
    return history;
  }

  // Delete individual history item
  void deleteHistory(HistoryItem historyItem) async {
    await HistoryService().deleteHistoryItem(historyItem);
    setState(() {
      _history = fetchSortedHistory(); // Refresh sorted history
    });
  }

  // Delete all history records
  void deleteAllHistory() async {
    await HistoryService().clearHistory();
    setState(() {
      _history = fetchSortedHistory(); // Refresh sorted history
    });
  }

  // Copy to clipboard
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Delete All button
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete All History'),
                    content: Text('Are you sure you want to delete all history?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                          deleteAllHistory();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HistoryItem>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading history'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No history available.'));
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    '${item.action}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueAccent,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'Input: ${item.inputText}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Output: ${item.outputText}',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Language: ${item.sourceLanguage} → ${item.targetLanguage}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy, color: Colors.green),
                        onPressed: () {
                          copyToClipboard(
                              '${item.inputText} → ${item.outputText}');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Delete individual history entry
                          deleteHistory(item);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
