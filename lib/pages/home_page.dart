import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_buzz/components/text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_buzz/components/wall_post.dart';
import 'package:social_buzz/components/my_drawer.dart';
import 'package:social_buzz/helper/date_formate_helper.dart';
import 'package:social_buzz/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    FirebaseFirestore.instance.collection('User Post').add({
      'messages': textMessageController.text,
      'UserEmail': currentUser.email,
      'TimeStamp': DateTime.now(),
      'likes': [],
    });
    textMessageController.clear();
  }

  final textMessageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      drawer: MyDrawer(
        profileOnTap: goToProfilePage,
        logoutOnTap: signOut,
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
          ),
        ],
        title: Text('Social Buzz'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // the wall
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User Post')
                    .orderBy('TimeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['messages'],
                          user: post['UserEmail'],
                          like: List<String>.from(
                            post['likes'] ?? [],
                          ),
                          postId: post.id,
                          time: formateDate(post['TimeStamp']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error ; ${snapshot.error}'),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            //textfield to post messages
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextField(
                        hintText: 'Write something on the wall...',
                        controller: textMessageController,
                        secureText: false),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: IconButton(
                      onPressed: postMessage,
                      icon: Icon(
                        Icons.arrow_circle_up,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // loggedin user
            Text('Logged in as : ' + currentUser.email.toString())
          ],
        ),
      ),
    );
  }
}
