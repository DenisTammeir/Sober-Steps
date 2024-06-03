import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/modules/auth/sign_up.dart';
import 'package:sober_steps/modules/soberity/soberity_start.dart';
import 'package:sober_steps/modules/widgets/bottom_bar.dart';

class VerifyEmail extends StatefulWidget {
  final page;
  const VerifyEmail({Key? key, this.page}) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      _stopTimer();
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'verified': true});
        _redirectToMainContent();
      } catch (e) {
        print('Error updating user document: $e');
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.sendEmailVerification();
        // Show a success message or perform any other desired action
      } catch (e) {
        print('Error sending verification email: $e');
      }
    }
  }

  Future<void> signOutUser() async {
    await FirebaseAuth.instance.signOut();
  }

  void _redirectToMainContent() {
    widget.page == 'start'
        ? Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => SobrietyStartPage()))
        : Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SoberityAuth()),
          );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email Verification'),
            content:
                const Text('Please complete the email verification process.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );

        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Email verification'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.fromLTRB(
                0, MediaQuery.of(context).size.height * .08, 0, 0),
            child: Column(
              children: [
                Container(
                  child: Image.asset(
                    'assets/sober.png',
                    fit: BoxFit.contain,
                    height: 70,
                    opacity: const AlwaysStoppedAnimation(.71),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                  child: const Text(
                    'A verification email has been sent to your email address. \nPlease check it to verify your account.',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    onPressed: _sendVerificationEmail,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: const Icon(Icons.email),
                        ),
                        const Text('Resend Email'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    onPressed: (() {
                      signOutUser();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    }),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: const Icon(Icons.cancel),
                        ),
                        const Text('Cancel'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VerificationAuth extends StatelessWidget {
  VerificationAuth({super.key});

  final userr = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> user =
        FirebaseFirestore.instance
            .collection('users')
            .doc(userr?.uid)
            .snapshots();
    print(userr?.uid);
    if (userr?.uid != null) {
      return Scaffold(
        body: StreamBuilder(
          stream: user,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            final users = snapshot.data;

            if (snapshot.hasData) {
              // Data is available, check the 'verified' field
              if (users['verified'] == true) {
                return SoberityAuth(); // Redirect to BottomBar widget
              } else {
                return const VerifyEmail(); // Redirect to VerifyEmail widget
              }
            }

            // If there is no data, you can show an empty container or a different widget
            return Container();
          },
        ),
      );
    } else {
      return const BottomBar();
    }
  }
}

class SoberityAuth extends StatelessWidget {
  SoberityAuth({super.key});

  final userr = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> user =
        FirebaseFirestore.instance
            .collection('sobriety')
            .doc(userr?.uid)
            .snapshots();
    print(userr?.uid);

    return Scaffold(
      body: StreamBuilder(
        stream: user,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData || snapshot.data.data() == null) {
            // Data is available, check the 'verified' field

            return SobrietyStartPage(); // Redirect to VerifyEmail widget

            // return VerifyEmail(); // Redirect to VerifyEmail widget
          } else {
            return const BottomBar(); // Redirect to BottomBar widget
          }

          // If there is no data, you can show an empty container or a different widget
          // return Container();
        },
      ),
    );
  }
}
