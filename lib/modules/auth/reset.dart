import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void wrongEmailMsg() {
    final snackBar = SnackBar(
      content: const Text('No user found.'),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).primaryColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future PasswordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _email.text.trim());

      final snackBar = SnackBar(
        content: const Text('Password reset link has been sent.'),
        duration: const Duration(seconds: 5),
        backgroundColor: Theme.of(context).primaryColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Username Test
        wrongEmailMsg();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * .9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Enter email to reset password.'),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  child: TextFormField(
                    controller: _email,
                    style: const TextStyle(color: Colors.black),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email!!';
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Please enter a valid email!!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      label: const Text('Email:'),
                      labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor, fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .8,
                  margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        final isValid = _formKey.currentState!.validate();

                        if (isValid) {
                          PasswordReset();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 6, 0),
                              child: Icon(
                                Icons.restore,
                                color: Colors.grey[100],
                              )),
                          Text(
                            'Reset Password',
                            style: TextStyle(color: Colors.grey[100]),
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
