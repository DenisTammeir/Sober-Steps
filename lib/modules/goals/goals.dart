import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/utils/goal_set.dart';

class ViewGoals extends StatefulWidget {
  final date;
  final formatedDate;
  const ViewGoals({super.key, required this.date, required this.formatedDate});

  @override
  State<ViewGoals> createState() => _ViewGoalsState();
}

class _ViewGoalsState extends State<ViewGoals> {
  // List<String> goals = [
  //   "Maintain sobriety for 30 consecutive days.",
  //       "Attend support group meetings at least three times a week.",
  //       "Develop healthy coping mechanisms for managing stress.",
  //       "Establish a daily exercise routine for physical and mental well-being.",
  //       "Build a strong support network of family and friends.",
  //       "Engage in regular therapy sessions to address underlying issues contributing to addiction.",
  // ];

  Map<String, bool?> goalStatus = {};

  @override
  void initState() {
    super.initState();
    // Initialize goal status map with all goals as not achieved
    // for (var goal in goals) {
    //   goalStatus[goal] = false;
    // }
  }

  @override
  Widget build(BuildContext context) {
    final _auth = FirebaseAuth.instance;
    String userid = _auth.currentUser!.uid;
    var selectedDate = widget.date;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.formatedDate,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('goals')
                    .where('userid', isEqualTo: userid)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // While waiting for the result, you can return a loading indicator or null.
                                  // return CircularProgressIndicator(); // Replace with your loading indicator.
                                  return Center();
                                }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No goals yet.'));
                  }
                  // final goalDocs = snapshot.data!.docs;
                  List<DocumentSnapshot> goalDocs =
                      snapshot.data!.docs.where((doc) {
                    // Extract the timestamp from the document and convert it to a DateTime object
                    DateTime docDateTime =
                        (doc['timestamp'] as Timestamp).toDate();

                    // Extract the year, month, and day parts from the document's DateTime object
                    int docYear = docDateTime.year;
                    int docMonth = docDateTime.month;
                    int docDay = docDateTime.day;

                    // Extract the year, month, and day parts from the selected date's DateTime object
                    int selectedYear = selectedDate.year;
                    int selectedMonth = selectedDate.month;
                    int selectedDay = selectedDate.day;

                    // Compare the year, month, and day parts to check if they match
                    return docYear == selectedYear &&
                        docMonth == selectedMonth &&
                        docDay == selectedDay;
                  }).toList();

                  return ListView.builder(
                    itemCount: goalDocs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final goals =
                          goalDocs[index].data() as Map<String, dynamic>;

                      final goal = goals['goal'] as String;
                      final id = goals['id'] as String;
                      final done = goals['done'] as bool;

                      // final goal = goals[index];
                      return Container(
                        margin: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        // height: 200,
                        child: GoalListItem(
                          goalText: goal,
                          isAchieved: done,
                          onChanged: (value) {
                            setState(() async {
                              await FirebaseFirestore.instance
                                  .collection('goals')
                                  .doc(id)
                                  .update({'done': !done});
                            });
                          },
                        ),
                      );
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }
}
