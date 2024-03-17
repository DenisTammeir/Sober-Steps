import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sober_steps/modules/widgets/bottom_bar.dart';

class UserAddictionsPage extends StatefulWidget {
  @override
  _UserAddictionsPageState createState() => _UserAddictionsPageState();
}

class _UserAddictionsPageState extends State<UserAddictionsPage> {
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BottomBar(),
          GestureDetector(
            onTap: () {
              // Close the menu when tapped outside
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.black
                    .withOpacity(0.3), // Adjust the opacity as needed
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
              // height:  MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 2 / 3,
              color: Colors.green[500],
              child: Column(
                children: [
                  Container(
                    height:  MediaQuery.of(context).size.height - 100,
                    child: Drawer(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.zero)),
                      backgroundColor: Colors.grey[100],
                      child: FutureBuilder<DocumentSnapshot>(
                        future: _firestore
                            .collection('sobriety')
                            .doc(_auth.currentUser!.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            List<dynamic>? addictions =
                                snapshot.data!.get('addictions');
                  
                            if (addictions == null || addictions.isEmpty) {
                              return Center(child: Text('No addictions found.'));
                            }
                  
                            return ListView.builder(
                              itemCount: addictions.length,
                              itemBuilder: (context, index) {
                                String addiction = addictions[index]['addiction'];
                                DateTime startDate =
                                    addictions[index]['start_date'].toDate();
                  
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    color: Colors.grey[200],
                                    child: ListTile(
                                      title: Text(
                                        addiction,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                          'Start Date: ${startDate.toString()}'),
                                      // Add onTap function if needed
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    // color: Colors.cyan,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
