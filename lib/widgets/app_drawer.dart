import 'package:flutter/material.dart';
import 'package:kapampangan_translator/screens/dictionary_screen.dart';
import 'package:kapampangan_translator/screens/phrasebook_screen.dart';
import 'package:kapampangan_translator/screens/history_page.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFEDEAFD),
            ),
            child: Text(
              'Translator Menu',
              style: TextStyle(
                color: Colors.black,
                fontSize: 42,
                fontFamily: 'Cursive',
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Dictionary'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DictionaryScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text('Phrasebook'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PhrasebookScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
