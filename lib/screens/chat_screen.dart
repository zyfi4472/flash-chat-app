import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const String id = 'chat_screen';

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool showSpiner = false;
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  final _firestore = FirebaseFirestore.instance;
  String? messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    FirebaseAuth.instance.signOut();
    super.dispose();
  }

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      // You have a non-null user object, you can work with it here
      loggedInUser = user;
      print(loggedInUser.email);
    } else {
      // There is no authenticated user

      print('No user is logged in');
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection("messages").get();

  //   for (var message in messages.docs) {
  //     print(message.data());
  //   }
  // }

  void getMessagesStream() async {
    await for (var snapshot in _firestore.collection("messages").snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                getMessagesStream();
                // FirebaseAuth.instance.signOut();
                // Navigator.pushNamed(context, LoginScreen.id);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpiner,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("messages").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final messages = snapshot.data?.docs;
                  List<Widget> messageWidgets = [];

                  if (messages != null) {
                    for (var message in messages) {
                      final messageData = message.data()
                          as Map<String, dynamic>; // Explicit cast to Map

                      final messageText =
                          messageData['value'] as String?; // Cast to String
                      final messageSender = messageData['sender'] as String?;

                      if (messageText != null && messageSender != null) {
                        final messageWidget =
                            Text('$messageText from $messageSender');
                        messageWidgets.add(messageWidget);
                      }
                    }
                  }

                  return Column(
                    children: messageWidgets,
                  );
                },
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          //Do something with the user input.
                          messageText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        //Implement send functionality.

                        _firestore.collection('messages').add({
                          'sender': loggedInUser.email,
                          'value': messageText,
                        });
                      },
                      child: const Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
