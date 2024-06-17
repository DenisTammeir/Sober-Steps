// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sober_steps/modules/auth/login.dart';
import 'package:sober_steps/modules/auth/reset.dart';
import 'package:sober_steps/modules/profile/about.dart';
import 'package:sober_steps/modules/profile/bio.dart';
import 'package:sober_steps/modules/sos/sos.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final password = TextEditingController();
  var _isPasswordVisible = true;

  final _formKey = GlobalKey<FormState>();

  void wrongPasswordMsg() {
    final snackBar = SnackBar(
      content: const Text('Wrong password.'),
      duration: const Duration(seconds: 3),
     backgroundColor: Theme.of(context).colorScheme.error,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void error() {
    final snackBar = SnackBar(
      content: const Text('An error occurred.'),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).colorScheme.error,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void signin() async {
    try {
      final user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: FirebaseAuth.instance.currentUser?.email ?? '',
        password: password.text.trim(),
      ))
          .user;

      if (user != null) {
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (context) => BottomBar()));
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Delete Account'),
                content: const Text(
                    'This will remove your account and delete all your data. This is permanent and cannot be undone!! \n\n'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      // Implement delete functionality here
                      // For example, delete the image from Firestore
                      // Then close the dialog
                      // Get the Firestore instance
                      try {
                        // Step 1: Delete user data from Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .delete();

                        await FirebaseFirestore.instance
                            .collection('sobriety')
                            .doc(user.uid)
                            .delete();

                        // Step 2: Optionally delete user files from Firebase Storage
                        // This is an example of how you might delete a user's profile picture
                        // final storageRef = FirebaseStorage.instance.ref();
                        // final profilePicRef = storageRef.child('profile_pics/${user.uid}.jpg');
                        // await profilePicRef.delete();

                        // Step 3: Delete user authentication record
                        await user.delete();

                        // Step 4: Optionally sign the user out after deleting the account
                        await FirebaseAuth.instance.signOut();

                        // Show success message and navigate to the login screen or home screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account successfully deleted.'),
                            backgroundColor: Color.fromARGB(255, 151, 112, 2),
                          ),
                        );

                        // Navigate to login screen or home screen
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: ((context) => LoginPage())));

                        SystemNavigator.pop(); // This line closes the app
                      } catch (e) {
                        // Handle errors, such as re-authentication required or network issues
                        if (e is FirebaseAuthException &&
                            e.code == 'requires-recent-login') {
                          // Ask the user to re-authenticate
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please re-authenticate to delete your account.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          // Navigate to re-authentication screen
                          delete();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'An error occurred while deleting the account.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red[400],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Close the dialog without deleting
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Remain',
                      style: TextStyle(
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              );
            });
      } else {
        Navigator.pop(context);
        error();
      }
    } on FirebaseAuthException catch (e) {
      // Navigator.pop(context);
      // print(e.code);
      if (e.code == 'invalid-credential') {
        // Password Test
        Navigator.pop(context);
        wrongPasswordMsg();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAc = FirebaseAuth.instance.currentUser;
    final userid = userAc?.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 3,
        title: Text(
          '    Profile',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.grey[100],
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 'Leave',
                  child: Text('Leave'),
                ),
              ],
              onSelected: (value) async {
                // Handle menu item selection
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Do you want to logout?\n\n'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              // Implement delete functionality here
                              // For example, delete the image from Firestore
                              // Then close the dialog
                              // Get the Firestore instance
                              void signOutUser() {
                                FirebaseAuth.instance.signOut().then((value) =>
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                LoginPage()))));
                                SystemNavigator
                                    .pop(); // This line closes the app
                              }

                              signOutUser();
                            },
                            child: Text(
                              'Log out',
                              style: TextStyle(
                                color: Colors.yellow[500],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Close the dialog without deleting
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Remain Active',
                              style: TextStyle(
                                color: Colors.grey[100],
                              ),
                            ),
                          ),
                        ],
                      );
                    });
              },
              icon: const Icon(
                Icons.more_vert_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('userid', isEqualTo: userid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container();
            }
            if (snapshot.error != null) {
              return const Center(
                child: Text('Error...'),
              );
            }

            final userdata = snapshot.data!.docs.first;
            final userInfo = userdata.data();
            final username = userInfo['username'];
            final email = userInfo['email'];
            final profile = userInfo['profile'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 64.0,
                        backgroundColor: Colors.blue,
                        // backgroundImage: AssetImage('assets/nature.jpg'), // Replace this with your image
                      ),
                      Positioned(
                        left: 4,
                        top: 4,
                        child: CircleAvatar(
                          radius: 60.0,
                          // backgroundImage: AssetImage(
                          //     'assets/nature.jpg'), // Replace this with your image
                          backgroundImage: profile != null
                              ? NetworkImage(profile)
                              : const AssetImage('assets/nature.jpg')
                                  as ImageProvider, // Replace this with your image
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    username, // Replace with the user's name
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      // color: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    email, // Replace with the user's email
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      // Add functionality to edit profile
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Bio(),
                      ));
                    },
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 50, 24, 6),
                    // height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16))),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('SOS'),
                      onTap: () {
                        // Add functionality to navigate to personal information page
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SOS(),
                        ));

                        // Navigator.of(context).push(MaterialPageRoute(
                        //   builder: (context) => AddCommunities(),
                        // ));
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 14, 24, 6),
                    // height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16))),
                    child: ListTile(
                      leading: const Icon(Icons.apps),
                      title: const Text('About'),
                      onTap: () {
                        // Add functionality to navigate to personal information page
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const About(),
                        ));
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 14, 24, 6),
                    // height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16))),
                    child: ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      onTap: () {
                        // Add functionality to navigate to change password page
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: ((context) => const ResetPassword())));
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 14, 24, 6),
                    // height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16))),
                    child: ListTile(
                      leading: const Icon(Icons.delete_forever_outlined),
                      title: const Text('Delete Account'),
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete Account'),
                                content: const Text(
                                    'Do you want to delete your account?\n\n'),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      // Implement delete functionality here
                                      // For example, delete the image from Firestore
                                      // Then close the dialog
                                      // Get the Firestore instance
                                      Navigator.pop(context);
                                      delete();
                                    },
                                    child: Text(
                                      'Remove Account',
                                      style: TextStyle(
                                        color: Colors.red[200],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Close the dialog without deleting
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Remain Sober',
                                      style: TextStyle(
                                        color: Colors.grey[100],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  void delete() {
    showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _formKey,
            child: AlertDialog(
              // title: const Text('Delete Account'),
              // content: const Text(
              //     'Do you want to delete your account?\n\n'),
              actions: [
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
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    // Implement login logic here
                    final isValid = _formKey.currentState!.validate();
                    if (isValid) {
                      signin();
                    }
                  },
                  child: const Text('Log In'),
                ),
              ],
            ),
          );
        });
  }
}
