import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AdminSectionUI extends StatefulWidget {
  final users;
  final id;

  const AdminSectionUI({super.key, required this.users, required this.id});

  @override
  State<AdminSectionUI> createState() => _AdminSectionUIState();
}

class _AdminSectionUIState extends State<AdminSectionUI> {
  @override
  Widget build(BuildContext context) {
    String searchText = '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Section'),
        actions: [
          IconButton(
            icon:
                Icon(Icons.person), // Replace with admin's profile avatar/icon
            onPressed: () {
              // Action when admin profile is tapped
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value
                      .toLowerCase(); // Update the searchText on text changes
                });
                // Implement search functionality
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sort by:'),
                DropdownButton<String>(
                  value: 'Name', // Default sorting option
                  onChanged: (newValue) {
                    // Implement sorting functionality
                  },
                  items: <String>[
                    'Name',
                    'Date Added',
                    // Add more sorting options as needed
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: ElevatedButton(
              onPressed: () {
                // Action when "Add User" button is tapped
              },
              child: Text('Add User'),
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('communities')
                    .where('id', isEqualTo: widget.id)
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
                    return Column(
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        const Center(
                            child: Text(
                                'No communities joined.\nJoin a community and get motivated.')),
                      ],
                    );
                  }
                  final userData = snapshot.data!.docs;
                  final people = userData.isNotEmpty
                      ? List<String>.from(userData.first['users'])
                      : [];

                  final List<Stream<QuerySnapshot>> queryStreams = [];
                  const int batchSize = 10;

                  for (int i = 0; i < people.length; i += batchSize) {
                    final batchIds = people.skip(i).take(batchSize).toList();

                    var queryStream = FirebaseFirestore.instance
                        .collection('users')
                        .where('userid', whereIn: batchIds)
                        .snapshots();

                    queryStreams.add(queryStream);
                    print(batchIds);
                  }

                  return StreamBuilder<List<QuerySnapshot>>(
                      stream: CombineLatestStream.list(queryStreams),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('No users to show.'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }
                        if (snapshot.error != null) {
                          return const Center(
                            child: Text('Error loading users.'),
                          );
                        }

                        final List<QuerySnapshot<Object?>> snapshots = snapshot
                            .data!; // Assuming snapshot.data is a List<QuerySnapshot>

// Iterate over each QuerySnapshot
                        final List users = snapshots.expand((snapshot) {
                          final userDocs = snapshot
                              .docs; // Accessing the docs property of each QuerySnapshot
                          return userDocs.where((sos) {
                            final username = sos['username']!
                                .toLowerCase(); // Accessing data using []
                            final searchQuery = searchText.toLowerCase();
                            return username.contains(searchQuery);
                          });
                        }).toList();

                        return ListView.builder(
                          itemCount: users.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final user =
                                users[index].data() as Map<String, dynamic>;

                            final name = user['username'] as String;
                            final userid = user['userid'] as String;
                            // final profile = community['profile'] as String;
                            // final id = community['id'] as String;

                            return ListTile(
                              leading: CircleAvatar(
                                // Replace with user's profile avatar/icon
                                child: Text('${index + 1}'),
                              ),
                              title: Text(name), // Replace with user's name
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle),
                                onPressed: () {
                                  // Action when "Remove" button is tapped
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirm Removal'),
                                        content: Text(
                                            'Do you want to remove user $name?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              // Dismiss the alert dialog
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              // Call the onConfirm function to remove the user
                                              await FirebaseFirestore.instance
                                                  .collection('communities')
                                                  .doc(widget.id)
                                                  .update({
                                                'users': FieldValue.arrayRemove(
                                                    [userid]),
                                              }).then((_) {
                                                print('User leave successful');
                                              }).catchError((error) {
                                                print('Error leaving: $error');
                                              });
                                              // Dismiss the alert dialog
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Confirm'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}
