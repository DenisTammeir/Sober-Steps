import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Bio extends StatelessWidget {
  const Bio({super.key});

  @override
  Widget build(BuildContext context) {
    final userAc = FirebaseAuth.instance.currentUser;
    final userid = userAc?.uid;

    return StreamBuilder(
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
              child: Text('Error loading bio.'),
            );
          }

          final userdata = snapshot.data!.docs.first;
          final userInfo = userdata.data();
          final myUsername = userInfo['username'];
          final TextEditingController _username =
              TextEditingController(text: userInfo['username']);
          return Scaffold(
            body: Container(
              color: Theme.of(context).colorScheme.background,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
                margin: EdgeInsets.fromLTRB(20, 50, 20, 30),
                height: 240,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userid)
                                .update({
                              'username': _username.text.trim(),
                            });
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.check_circle_outline_outlined,
                            size: 30,
                            color: Theme.of(context).colorScheme.background,
                          )),
                    ),
                    // SizedBox(height: 40,),
                    TextFormField(
                      controller: _username,
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
                  ],
                ),
              ),
            ),
          );
        });
  }
}
