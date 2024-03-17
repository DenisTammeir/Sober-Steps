import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Reviews extends StatelessWidget {
  const Reviews({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('assesments')
            .where('userid', isEqualTo: user?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center();
          // }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Container(
              child: Text(
                  'Stay positive. You have the power to change your path.',
                   style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontStyle: FontStyle.italic),
                  ),
            );
          }
          if (snapshot.error != null) {
            return const Center(
              child: Text(
                  'You are capable of achieving your goals. Keep believing!',
                   style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontStyle: FontStyle.italic),
                  ),
            );
          }

          final reviewdata = snapshot.data!.docs.first;
          final reviewInfo = reviewdata.data();
          final quote = reviewInfo['quote'];
          return Container(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Text(
              quote,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontStyle: FontStyle.italic),
            ),
          );
        });
  }
}
