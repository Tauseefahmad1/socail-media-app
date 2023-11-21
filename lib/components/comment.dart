import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment({required this.text, required this.user, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          Row(
            children: [
              Text(
                user,
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
              Text(' . '),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
