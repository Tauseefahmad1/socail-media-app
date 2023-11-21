import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_buzz/components/comment.dart';
import 'package:social_buzz/components/comment_button.dart';
import 'package:social_buzz/components/delete_button.dart';
import 'package:social_buzz/components/like_button.dart';
import 'package:social_buzz/helper/date_formate_helper.dart';

class WallPost extends StatefulWidget {
  WallPost({
    required this.message,
    required this.user,
    required this.like,
    required this.postId,
    required this.time,
  });
  final String time;
  final String message;
  final String user;
  final String postId;
  final List<String> like;

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  final commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.like.contains(currentUser.email);
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection('User Post')
        .doc(widget.postId)
        .collection('comment')
        .add({
      'commentText': commentText,
      'commentedBy': currentUser.email,
      'commentTime': Timestamp.now(),
    });
  }

  void showCommentDailogue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Add comment',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          style: TextStyle(
            color: Colors.white,
          ),
          controller: commentTextController,
          cursorColor: Colors.white,
          autofocus: true,
          decoration: InputDecoration(
            focusColor: Colors.white,
            hintText: 'write comment here...',
            hintStyle: TextStyle(color: Colors.white),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              commentTextController.clear();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              addComment(commentTextController.text);
              Navigator.pop(context);
              commentTextController.clear();
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Post').doc(widget.postId);
    if (isLiked) {
      postRef.update({
        'likes': FieldValue.arrayUnion([currentUser.email]),
      });
    } else {
      postRef.update({
        'likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  void deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Delete post',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure ? ',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              final commentDocs = await FirebaseFirestore.instance
                  .collection('User Post')
                  .doc(widget.postId)
                  .collection('comment')
                  .get();
              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection('User Post')
                    .doc(widget.postId)
                    .collection('comment')
                    .doc(doc.id)
                    .delete();
              }
              FirebaseFirestore.instance
                  .collection('User Post')
                  .doc(widget.postId)
                  .delete();
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white),
      margin: EdgeInsets.only(left: 25, right: 25, top: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.message),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      Text(' . '),
                      Text(
                        widget.time,
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  if (widget.user == currentUser.email)
                    DeleteButton(onTap: deletePost),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      LikeButton(onTap: toggleLike, isLiked: isLiked),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.like.length.toString(),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    children: [
                      CommentButton(onTap: showCommentDailogue),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '0',
                      ),
                    ],
                  ),
                ],
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User Post')
                    .doc(widget.postId)
                    .collection('comment')
                    .orderBy(
                      'commentTime',
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: snapshot.data!.docs.map((doc) {
                      final commentData = doc.data() as Map<String, dynamic>;
                      return Comment(
                        text: commentData['commentText'],
                        user: commentData['commentedBy'],
                        time: formateDate(
                          commentData['commentTime'],
                        ),
                      );
                    }).toList(),
                  );
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
