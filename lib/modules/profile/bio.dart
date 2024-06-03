import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sober_steps/modules/profile/image_preview.dart';

class Bio extends StatelessWidget {
  const Bio({super.key});

  @override
  Widget build(BuildContext context) {
    final userAc = FirebaseAuth.instance.currentUser;
    final userid = userAc?.uid;


  Future<void> _selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewPage(image: File(pickedFile.path)),
        ),
      );
    }
  }

  
     Future<void> requestStoragePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with image selection
      _selectImage();
    }
  }
  

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
                height: 340,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Update Profile', // Replace with the user's name
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.background,
                            // color: Colors.grey[100],
                          ),
                        ),
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
                                size: 36,
                                color: Theme.of(context).colorScheme.background,
                              )),
                        ),
                      ],
                    ),

                    Container(
                       padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: requestStoragePermission,
                            child: CircleAvatar(
                              radius: 50,
                              foregroundImage: userInfo['profile'] != null
                                  ? NetworkImage(userInfo['profile']!)
                                  : null,
                              child: Icon(
                                Icons.person_3_outlined,
                                size: 40,
                                color: Theme.of(context).shadowColor,
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 6,
                            right: 6,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Color.fromARGB(255, 6, 130, 231),
                              child: Icon(
                                Icons.add,
                                size: 20,
                              ),
                            ),
                          )
                        ],
                      ),
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
