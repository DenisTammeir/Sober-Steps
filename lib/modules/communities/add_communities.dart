import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddCommunities extends StatefulWidget {
  AddCommunities({super.key});

  @override
  State<AddCommunities> createState() => _AddCommunitiesState();
}

class _AddCommunitiesState extends State<AddCommunities> {
  final name = TextEditingController();

  final description = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage() async {
    if (_image == null) return;

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('community_profile/${DateTime.now()}.png');
    UploadTask uploadTask = storageReference.putFile(_image!);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 200,
              ),
              _image != null
                  ? GestureDetector(
                      onTap: getImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(_image!),
                      ),
                    )
                  : GestureDetector(
                      onTap: getImage,
                      child: CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person),
                      ),
                    ),
              Center(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                  width: MediaQuery.of(context).size.width * .88,
                  height: 60,
                  child: TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Community name',
                    ),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the community name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                //  padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
                width: MediaQuery.of(context).size.width * .88,
                height: 60,
                child: TextFormField(
                  controller: description,
                  decoration: const InputDecoration(
                    labelText: 'Community Descritpion',
                  ),
                  keyboardType: TextInputType.text,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Please enter the community name';
                  //   }
                  //   return null;
                  // },
                ),
              ),
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 30, 0, 10),
                  //  padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
                  width: MediaQuery.of(context).size.width * .88,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final isValid = _formKey.currentState!.validate();
                      String userId = _auth.currentUser!.uid;
                      if (isValid) {
                        String? imageUrl = await uploadImage();
                        try {
                          FirebaseFirestore firestore =
                              FirebaseFirestore.instance;

                          // Get the collection reference
                          CollectionReference collectionRef =
                              firestore.collection('communities');

                          // Add data to the collection
                          DocumentReference documentRef =
                              await collectionRef.add({
                            // 'userid': user?.uid,
                            'timestamp': FieldValue.serverTimestamp(),
                            'name': name.text.trim(),
                            'description': description.text.trim(),
                            'admin': userId,
                            'users': [userId],
                            'profile': imageUrl ?? '',
                            // 'value': randomValue,
                          });

                          // Update the document to add the ID field
                          await documentRef.update({'id': documentRef.id});

                          // Show success message or navigate to another page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Community created successfully!')),
                          );
                        } catch (e) {
                          print('Error creating community: $e');
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Failed to create community. Please try again later.')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('Add Community'),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
