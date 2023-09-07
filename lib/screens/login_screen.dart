import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_app/constants.dart';
import 'package:flash_chat_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../components/my_button.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? email, password;
  bool showSpiner = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void signIn() {
    setState(() {
      showSpiner = true;
    });

    if (email?.isEmpty != false && password?.isEmpty != false) {
      setState(() {
        showSpiner = false;
      });
      Fluttertoast.showToast(
        msg: "Please fill in both email and password fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black45,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      print('Valid email and password provided');

      _auth.signInWithEmailAndPassword(email: email!, password: password!).then(
        (userCredential) {
          // Sign-in was successful, handle it here.
          Navigator.pushNamed(context, ChatScreen.id);
          print('Login in success');
          setState(() {
            showSpiner = false;
          });
        },
      ).catchError(
        (error) {
          // Sign-in failed, handle the error here.
          print('Login unsuccessful: $error');
          setState(() {
            showSpiner = false;
          });
        },
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpiner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Hero(
                tag: 'logo',
                child: SizedBox(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              TextField(
                onChanged: (value) {
                  email = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              const SizedBox(
                height: 24.0,
              ),
              MyButton(
                onPressed: signIn,
                color: lightBlue,
                buttonText: 'Login',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
