import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_buzz/components/button.dart';
import 'package:social_buzz/components/text_field.dart';
import 'package:social_buzz/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  SignupPage({required this.onTap});
  final void Function()? onTap;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailTextController = TextEditingController();

  final passwordTextController = TextEditingController();

  final confirmPasswordTextController = TextEditingController();

  void signUp() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
    if (passwordTextController.text != confirmPasswordTextController.text) {
      Navigator.pop(context);
      displayMessage("password do'nt match");
      return;
    }
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );
      FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.email)
          .set(
        {
          'username': emailTextController.text.split('@')[0],
          'bio': 'empty bio..'
        },
      );
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Icon(
                    Icons.lock,
                    size: 100,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'welcome back you have been missed!',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  MyTextField(
                    hintText: 'Email',
                    controller: emailTextController,
                    secureText: false,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyTextField(
                    hintText: 'password',
                    controller: passwordTextController,
                    secureText: true,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MyTextField(
                    hintText: 'Confirm Password',
                    controller: confirmPasswordTextController,
                    secureText: true,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MyButton(text: 'Signup', onTap: signUp),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have acount ?',
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'LogIn',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
