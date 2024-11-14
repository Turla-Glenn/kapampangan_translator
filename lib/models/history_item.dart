// lib/models/history_item.dart
class HistoryItem {
  final String action;
  final String inputText;
  final String outputText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;

  HistoryItem({
    required this.action,
    required this.inputText,
    required this.outputText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'inputText': inputText,
      'outputText': outputText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static HistoryItem fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      action: map['action'],
      inputText: map['inputText'],
      outputText: map['outputText'],
      sourceLanguage: map['sourceLanguage'],
      targetLanguage: map['targetLanguage'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
