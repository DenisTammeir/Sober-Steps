import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/modules/communities/chats.dart';

class Communities extends StatefulWidget {
  final searchText;
  final isAdmin;
  const Communities({super.key, this.searchText, required this.isAdmin});

  @override
  State<Communities> createState() => _CommunitiesState();
}

class _CommunitiesState extends State<Communities> {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    String userId = _auth.currentUser!.uid;
    String searchText = widget.searchText;
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .where('users', arrayContains: userId)
            // .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While waiting for the result, you can return a loading indicator or null.
            // return CircularProgressIndicator(); // Replace with your loading indicator.
            return const Center();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Center(
                    child: Text(
                        'No communities joined.\nJoin a community and get motivated.')),
              ],
            );
          }
          final communityDoc = snapshot.data!.docs;

          final List communityDocs = communityDoc.where((sos) {
            final username = sos['name'].toLowerCase();
            final searchQuery = searchText.toLowerCase();
            return username.contains(searchQuery);
          }).toList();

          return ListView.builder(
              itemCount: communityDocs.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final community =
                    communityDocs[index].data() as Map<String, dynamic>;

                final name = community['name'] as String;
                final description = community['description'] as String;
                final profile = community['profile'] as String;
                final id = community['id'] as String;
                final users = community['users'] as List;
                final ispart = users.contains(userId);
                final members = users.length;

                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Chats(
                      
                      chatid: id,
                      name: name,
                      isPart: ispart, users: users, isAdmin: widget.isAdmin,
                      
                    ),
                  )),
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 6),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                // height: 7,
                                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                width: 80,
                                child: Stack(
                                  children: [
                                    const CircleAvatar(
                                      radius: 36,
                                      backgroundColor: Colors.blue,
                                    ),
                                    Positioned(
                                      left: 2,
                                      top: 2,
                                      child: CircleAvatar(
                                        radius: 34,
                                        foregroundImage: profile.isNotEmpty
                                            ? NetworkImage(profile)
                                            : null,
                                        child: const Icon(
                                            Icons.people_outline_outlined),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 200,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        // fontSize: 13
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '$members' +
                                          ' member${members > 1 ? 's' : ''} ',
                                      style: TextStyle(
                                        // fontSize: 13
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          !widget.isAdmin
                              ? ispart
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('communities')
                                            .doc(id)
                                            .update({
                                          'users':
                                              FieldValue.arrayRemove([userId]),
                                        }).then((_) {
                                          print('User leave successful');
                                        }).catchError((error) {
                                          print('Error leaving: $error');
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal:
                                                6), // Adjust padding as needed
                                      ),
                                      child: const Text(
                                        'Leave',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                            horizontal:
                                                6), // Adjust padding as needed
                                      ),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('communities')
                                            .doc(id)
                                            .update({
                                          'users':
                                              FieldValue.arrayUnion([userId]),
                                        }).then((_) {
                                          print('User joined successfully');
                                        }).catchError((error) {
                                          print('Error  joining: $error');
                                        });
                                      },
                                      child: const Text(
                                        'Join',
                                      ))
                              : Container(),
                        ]),
                  ),
                );
              });
        },
      ),
    );
  }
}
