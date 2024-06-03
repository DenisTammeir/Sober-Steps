import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ImagePreviewPage extends StatefulWidget {
  final File image;

  ImagePreviewPage({required this.image});

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
//  File? _profilePhoto;
  String? _profilePhotoUrl;
  bool isUploading = false;

  Future<void> _uploadProfilePhoto() async {
    if (widget.image == null) {
      return;
    }
    setState(() {
      isUploading = true;
    });

    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_photos/${DateTime.now().toString()}');
    final uploadTask = storageRef.putFile(widget.image);

    await uploadTask.whenComplete(() async {
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _profilePhotoUrl = downloadUrl;
        isUploading = false;
      });
    });
  }

  Future<void> _saveProfilePhoto() async {
    await _uploadProfilePhoto();
    if (_profilePhotoUrl == null) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'profile': _profilePhotoUrl,
    });
    Navigator.of(context).pop();
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   duration: const Duration(seconds: 2),
    //   backgroundColor: Theme.of(context).splashColor,
    //   content: const Text('Profile photo saved.'),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Image.file(widget.image),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveProfilePhoto();
          // Implement logic to save the image here
          // For example, you can use the image package to save the image to disk.
          // After saving, you can show a snackbar or navigate back to the profile page.
        },
        child: !isUploading
            ? const Icon(Icons.check)
            : const Text(
                'Uploading...',
                style: TextStyle(
                  fontSize: 6,
                ),
              ),
      ),
    );
  }
}
