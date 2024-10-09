import 'package:flutter/material.dart';

class TranslationBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.volume_up, color: Colors.grey),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.mic, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
