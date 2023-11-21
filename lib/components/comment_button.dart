import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  final void Function()? onTap;
  const CommentButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        Icons.mode_comment_sharp,
        color: Colors.grey,
      ),
    );
  }
}
