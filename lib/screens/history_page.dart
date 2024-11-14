import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/history_item.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<HistoryItem>> _history;

  @override
  void initState() {
    super.initState();
    _history = HistoryService().getHistory();
  }

  // Delete individual history item
  void deleteHistory(HistoryItem historyItem) async {
    await HistoryService().deleteHistoryItem(historyItem);
    setState(() {
      _history = HistoryService().getHistory();
    });
  }

  // Delete all history records
  void deleteAllHistory() async {
    await HistoryService().clearHistory();
    setState(() {
      _history = HistoryService().getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
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
              return ListTile(
                title: Text('${item.action}'),
                subtitle: Text('${item.inputText} → ${item.outputText}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Delete individual history entry
                    deleteHistory(item);
                  },
                ),
                isThreeLine: true,
                contentPadding: EdgeInsets.all(10),
              );
            },
          );
        },
      ),
    );
  }
}
