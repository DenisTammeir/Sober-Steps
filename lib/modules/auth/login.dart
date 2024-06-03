import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/modules/auth/sign_up.dart';
import 'package:sober_steps/modules/auth/verify_email.dart';
import 'package:sober_steps/modules/widgets/bottom_bar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isPasswordVisible = true;


  Future<void> saveFCMTokenToFirestore(String? userId) async {
    // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

    try {
      // Request the FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Save the FCM token to Firestore under the user's document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': fcmToken});

      if (kDebugMode) {
        print('FCM Token saved to Firestore: $fcmToken');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving FCM token: $e');
      }
    }
  }


  void wrongEmailMsg() {
    final snackBar = SnackBar(
      content: const Text('No user found.'),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).primaryColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void wrongPasswordMsg() {
    final snackBar = SnackBar(
      content: const Text('Wrong password.'),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).indicatorColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

   void signin() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.greenAccent,
              backgroundColor: Colors.grey,
            ),
          );
        });
    try {
      final user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      ))
          .user;
            saveFCMTokenToFirestore(user?.uid);

      Navigator.pop(context) ;

      if (user != null) {
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (context) => BottomBar()));

           Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => VerificationAuth()));

      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        // Username Test
        wrongEmailMsg();
      } else if (e.code == 'wrong-password') {
        // Password Test

        wrongPasswordMsg();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/nature.jpg'),
                fit: BoxFit.cover,
                opacity: .2,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please add an email!!';
                            } else if (!RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                              return 'Please enter a valid email!!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: password,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () async {
                            // Implement login logic here
                              final isValid =
                                        _formKey.currentState!.validate();
                                    if (isValid) {
                                      signin();
                                    }
                           
                          },
                          child: Text('Log In'),
                        ),
                        SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            // Navigate to sign-up page
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ));
                            ;
                          },
                          child: Text('Don\'t have an account? Sign up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
