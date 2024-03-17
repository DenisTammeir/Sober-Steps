import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/modules/auth/login.dart';
import 'package:sober_steps/modules/soberity/soberity_start.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
   final _username = TextEditingController();
   final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  void userEmail() {
    final snackBar = SnackBar(
      content: const Text('User already exist.'),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).indicatorColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void weakPassword() {
    final snackBar = SnackBar(
      content: const Text('Please enter a strong password.'),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).indicatorColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

Future<void> signUp() async {
    try {
      UserCredential user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      String uid = user.user!.uid;

      // String? fcmToken = await FirebaseMessaging.instance.getToken();
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': _email.text.trim(),
        'username': _username.text.trim(),
        'userid': uid,
        'profile': '',
        'createdAt': FieldValue.serverTimestamp(),
        
      });

      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) =>  SobrietyStartPage()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        // Username Test
        userEmail();
      } else if (e.code == 'WEAK_PASSWORD') {
        // Username Test
        weakPassword();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/nature.jpg'),
                  fit: BoxFit.cover,
                  opacity: .2),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.7),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
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
                          child:  Text(
                            'Create Account',
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
                          controller:  _username,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          controller: _password,
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
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                                    final isValid =
                                        _formKey.currentState!.validate();
                                    if (isValid) {
                                      signUp();
                                    }
                                  },
                          child: const Text('Sign Up'),
                        ),
                        const SizedBox(height: 20.0),
                        TextButton(
                          onPressed: () {
                            // Navigate to login page
                           Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage(),));
                          },
                          child: const Text('Already have an account? Log in'),
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
