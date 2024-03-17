import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddGoalPage extends StatefulWidget {
  @override
  _AddGoalPageState createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _goalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Add Goal'),
      // ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      'assets/lake.jpg'), // Replace 'assets/background_image.jpg' with your image path
                  fit: BoxFit
                      .cover, // Adjust the BoxFit according to your requirement
                  opacity: .8),
            ),
            // Other container properties like width, height, child, etc.
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                // color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text(
                  //   'Mood: $mood',
                  //   style: TextStyle(
                  //     fontSize: 18.0,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    height: 320,
                    child: Card(
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox(height: 10.0),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                              // height: 160,
                              child: Center(
                                child: TextField(
                                  controller: _goalController,
                                  maxLines: 5,
                                  minLines: 3,
                                  decoration: InputDecoration(
                                    labelText: 'Enter your goal',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .grey), // Adjust the color as needed
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .88,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 4,
                                    backgroundColor: const Color.fromARGB(
                                        255, 206, 242, 247),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)))),
                                onPressed: () async {
                                  // Perform assessment logic here

                                  _addGoalToFirestore();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Submit Goal',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addGoalToFirestore() async {
    String userId = _auth.currentUser!.uid;
    String goal = _goalController.text.trim();

    if (goal.isNotEmpty) {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Get the collection reference
        CollectionReference collectionRef = firestore.collection('goals');

        // Add data to the collection
        DocumentReference documentRef = await collectionRef.add({
          // 'userid': user?.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'goal': goal,
          'userid': userId,
          'done': false,
          //   'smoke': !positiveSmoke,
          // 'value': randomValue,
        });

        // Update the document to add the ID field
        await documentRef.update({'id': documentRef.id});

        // Show success message or navigate to another page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Goal added successfully!')),
        );
      } catch (e) {
        print('Error adding goal: $e');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add goal. Please try again later.')),
        );
      }
    } else {
      // Show error message if the goal field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a goal.')),
      );
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }
}
