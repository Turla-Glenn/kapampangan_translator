import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const String _historyKey = 'user_history';

  // Save history to SharedPreferences
  Future<void> saveHistory(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];
    historyJson.add(jsonEncode(item.toMap()));
    await prefs.setStringList(_historyKey, historyJson);
  }

  // Get all history records
  Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];
    return historyJson.map((e) => HistoryItem.fromMap(jsonDecode(e))).toList();
  }

  // Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Delete specific history item
  Future<void> deleteHistoryItem(HistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];
    historyJson.removeWhere((historyItem) => jsonDecode(historyItem)['timestamp'] == item.timestamp.toIso8601String());
    await prefs.setStringList(_historyKey, historyJson);
  }
}
