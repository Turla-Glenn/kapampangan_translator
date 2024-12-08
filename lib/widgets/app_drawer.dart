import 'package:flutter/material.dart';
import 'package:kapampangan_translator/screens/camera_page.dart';
import 'package:kapampangan_translator/screens/dictionary_screen.dart';
import 'package:kapampangan_translator/screens/microphone_page.dart';
import 'package:kapampangan_translator/screens/phrasebook_screen.dart';
import 'package:kapampangan_translator/screens/history_page.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blueGrey[50], // Soft background color
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Smaller Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Color(0xFF3F51B5), // Deep blue color for header
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24, // Smaller avatar
                    backgroundImage: AssetImage('assets/images/logo1.png'), // Add logo or image
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Ka Tag Lish',
                    style: GoogleFonts.molle(
                      color: Colors.white,
                      fontSize: 20, // Slightly smaller text size
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1), // Add spacing after the header
            // Drawer Items
            _buildDrawerItem(
              context,
              icon: Icons.camera_indoor,
              title: 'Camera Translation',
              route: CameraPage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.record_voice_over,
              title: 'Voice Translation',
              route: MicrophonePage(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.book,
              title: 'Dictionary',
              route: DictionaryScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.library_books,
              title: 'Phrasebook',
              route: PhrasebookScreen(),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.history,
              title: 'History',
              route: HistoryPage(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building ListTile with consistent style
  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        Widget? route,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Color(0xFF3F51B5), // Matching icon color with header
        size: 24, // Icon size
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14, // Font size
          fontWeight: FontWeight.w500, // Slightly lighter font weight
          color: Colors.black87,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      onTap: () {
        if (route != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Settings are not available yet.')),
          );
        }
      },
    );
  }
}
