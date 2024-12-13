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
      _phrases = data['data']; // Extract the data array from JSON
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('PhraseBook', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF3F51B5), // Professional background color
      ),
      body: _phrases.isEmpty
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(  // Use CustomScrollView for sticky header behavior
        slivers: [
          // Sticky Header
          SliverPersistentHeader(
            pinned: true,  // Pin the header so it stays at the top while scrolling
            delegate: _SliverAppBarDelegate(
              height: 80.0,  // Keep header height fixed
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100, // Light Teal background
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(  // Horizontal scrolling for the header
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildHeaderCell('Kapampangan', screenWidth * 0.3),
                      _buildHeaderCell('Filipino', screenWidth * 0.3),
                      _buildHeaderCell('English', screenWidth * 0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Divider between header and content
          SliverToBoxAdapter(
            child: Divider(),
          ),
          // List of Phrases
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final phrase = _phrases[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(  // Horizontal scrolling for data rows
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDataCell(phrase['kapampangan'], screenWidth * 0.3),
                        _buildDataCell(phrase['filipino'], screenWidth * 0.3),
                        _buildDataCell(phrase['english'], screenWidth * 0.3),
                      ],
                    ),
                  ),
                );
              },
              childCount: _phrases.length,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create header cells with professional styling
  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.teal[900], // Dark Teal text color for headers
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper method to create data cells with professional styling
  Widget _buildDataCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.black87), // More legible font size
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis, // Truncate text if it's too long
        maxLines: 4, // Limit the text to 4 lines
      ),
    );
  }
}

// Custom SliverPersistentHeaderDelegate to control the header size
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _SliverAppBarDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;  // Fix the minExtent to the height of the header

  @override
  double get maxExtent => height;  // Fix the maxExtent to the height of the header

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
