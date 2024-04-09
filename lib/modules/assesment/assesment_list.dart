import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sober_steps/modules/assesment/assesment_view.dart';
import 'package:sober_steps/modules/assesment/drug_assesment.dart'; // Import DateFormat

class AssessmentHistoryPage extends StatefulWidget {
  // final String userId;

  // AssessmentHistoryPage({ });

  @override
  _AssessmentHistoryPageState createState() => _AssessmentHistoryPageState();
}

class _AssessmentHistoryPageState extends State<AssessmentHistoryPage> {
  late List<DateTime> assessmentDates = []; // Initialize to an empty list
  List mood = [];
  List drink = [];
  List smoke = [];

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Fetch assessment dates from Firestore
    fetchAssessmentDates();
  }

  void fetchAssessmentDates() async {
    try {
      // Query Firestore collection "assessment" for assessment dates
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assesments')
          .where('userid', isEqualTo: user?.uid)
          .orderBy('timestamp', descending: true)
          .get();

      // Extract assessment dates from the query snapshot
      List<DateTime> dates = [];
      List<String> moods = [];
      List<bool> drinks = [];
      List<bool> smokes = [];

      querySnapshot.docs.forEach((doc) {
        Timestamp timestamp = doc['timestamp'] as Timestamp;
        String mood = doc['mood'] as String;
        bool drink = doc['drink'] as bool;
        bool smoke = doc['smoke'] as bool;

        dates.add(timestamp.toDate());
      });

      // Update the state with the fetched assessment dates
      setState(() {
        assessmentDates = dates;
        mood = moods;
        drink = drinks;
        smoke = smokes;
      });
    } catch (e) {
      print('Error fetching assessment dates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 3,
        title: Text(
          '   Assessment History',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.grey[100],
          ),
        ),
        actions: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('assesments')
                  .where('userid', isEqualTo: user?.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AssessmentPage(hasReviewed: false,),
                        ));
                      },
                      icon: const Icon(
                        Icons.add_reaction_outlined,
                        color: Colors.white,
                        size: 32,
                      ));
                }
                final assesments = snapshot.data!.docs.first;
                final userInfo = assesments.data();
                final timestamp = userInfo['timestamp'];

                // Get the date part from the timestamp
                DateTime dateFromTimestamp = timestamp.toDate();

// Get today's date
                DateTime today = DateTime.now();

// Check if the date part of the timestamp is equal to today's date
                bool isToday = dateFromTimestamp.year == today.year &&
                    dateFromTimestamp.month == today.month &&
                    dateFromTimestamp.day == today.day;

                return IconButton(
                    onPressed: () {
                      if (isToday) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                "Sober Mind",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              content: const Text(
                                "You have assessed today, would you like to assess again?",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text(
                                    "Assess",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 182, 238, 171),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context); // Close the alert dialog
                                    // Add your logic here for when the "Assess" button is pressed
                                    // For example, you can navigate to the assessment screen
                                    Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AssessmentPage(hasReviewed: true,),
                        )); // Close the alert dialog
                          
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AssessmentPage(hasReviewed: false,),
                        ));
                      }
                    },
                    icon: const Icon(
                      Icons.add_reaction_outlined,
                      color: Colors.white,
                      size: 32,
                    ));
              }),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('assesments')
                .where('userid', isEqualTo: user?.uid)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No reviews yet.'));
              }
              final assesments = snapshot.data!.docs;

              return ListView.builder(
                  itemCount:
                      assesments.length, // +1 for the current date option
                  itemBuilder: (context, index) {
                    // Render the assessment history
                    // final date = assessmentDates[index - 1];

                    final assess =
                        assesments[index].data() as Map<String, dynamic>;

                    final mood = assess['mood'] as String?;
                    final quote = assess['quote'] as String?;
                    final drink = assess['drink'] as bool;
                    final smoke = assess['smoke'] as bool;
                    final date = assess['timestamp']?.toDate();

                    return Container(
                      margin: const EdgeInsets.fromLTRB(22, 3, 22, 3),
                      // height: 50,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: ListTile(
                        title: Text(
                          '${DateFormat.E().format(date!)}, ${DateFormat.MMMd().format(date)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            // color: Colors.white,
                          ),
                        ),
                        subtitle: Container(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mood: ${mood}'),
                              drink
                                  ? Text('Drink: ${drink ? 'Yes' : 'No'}')
                                  : Container(),
                              smoke
                                  ? Text('Smoke: ${smoke ? 'Yes' : 'No'}')
                                  : Container(),
                            ],
                          ),
                        ),
                        // You can add more details here if needed
                        onTap: () {
                          // Handle tapping on an assessment date if necessary
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AssesmentView(
                              quote: quote,
                              date: date,
                              mood: mood,
                            ),
                          ));
                        },
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
