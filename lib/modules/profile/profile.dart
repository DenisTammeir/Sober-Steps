import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/modules/auth/login.dart';
import 'package:sober_steps/modules/communities/add_communities.dart';
import 'package:sober_steps/modules/communities/communities.dart';
import 'package:sober_steps/modules/communities/community_tab.dart';
import 'package:sober_steps/modules/profile/about.dart';
import 'package:sober_steps/modules/profile/bio.dart';
import 'package:sober_steps/modules/sos/add_sos.dart';
import 'package:sober_steps/modules/sos/sos.dart';

class ProfilePage extends StatelessWidget {
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Stack(
                    children: [
                      CircleAvatar(
                        radius: 64.0,
                        backgroundColor: Colors.blue,
                        // backgroundImage: AssetImage('assets/nature.jpg'), // Replace this with your image
                      ),
                      Positioned(
                        left: 4,
                        top: 4,
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundImage: AssetImage(
                              'assets/nature.jpg'), // Replace this with your image
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
                        builder: (context) => Bio(),
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
                          builder: (context) => SOS(),
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

                  //  Container(
                  //   margin: const EdgeInsets.fromLTRB(24, 50, 24, 6),
                  //   // height: 50,
                  //   decoration: BoxDecoration(
                  //       color: Colors.grey[300],
                  //       borderRadius: const BorderRadius.all(Radius.circular(16))),
                  //   child: ListTile(
                  //     leading: const Icon(Icons.person),
                  //     title: const Text('Personal Information'),
                  //     onTap: () {
                  //       // Add functionality to navigate to personal information page
                  //     },
                  //   ),
                  // ),
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
                        // Navigator.of(context).push(MaterialPageRoute(
                        //   builder: (context) => CommunityTab(),
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
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        // Add functionality to logout
                         await FirebaseAuth.instance.signOut();
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  LoginPage()));
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
