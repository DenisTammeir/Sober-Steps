import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/modules/assesment/day_assesment.dart';

class AssessmentPage extends StatefulWidget {
  final bool hasReviewed;

  const AssessmentPage({super.key, required this.hasReviewed});
  @override
  _AssessmentPageState createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  bool hasSmokedTobacco = false;
  bool hasHadDrink = false;
  bool hasSmoke = false;
  bool hasDrink = false;
  int tobaccoCount = 0;
  int drinkCount = 0;
  Timestamp drinkDate = Timestamp.fromDate(DateTime.now());
  Timestamp smokeDate = Timestamp.fromDate(DateTime.now());
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Fetch existing sobriety start data from Firestore
    fetchSobrietyData();
  }

  Future<void> fetchSobrietyData() async {
    try {
      // Retrieve the user's document from Firestore
      DocumentSnapshot snapshot = await _firestore
          .collection('sobriety')
          .doc(_auth.currentUser!.uid)
          .get();

      // Check if the document exists and contains sobriety data
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

        // Check if data is not null and contains the 'addictions' key
        if (data != null && data.containsKey('addictions')) {
          // Get the list of addictions
          List<dynamic>? addictions = data['addictions'];
          Map<String, Timestamp> addictionDates = {};

          // Loop through each addiction entry
          for (var addictionEntry in addictions!) {
            var addiction = addictionEntry['addiction'];
            var dates = addictionEntry['start_date'];
            addictionDates[addiction] = dates;
            // Check the type of addiction and update state variables accordingly
            if (addiction == 'Alcohol') {
              setState(() {
                hasDrink = true;
                drinkDate = addictionDates['Alcohol']!;
              });
            } else if (addiction == 'Smoking') {
              setState(() {
                hasSmoke = true;
                smokeDate = addictionDates['Smoking']!;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching sobriety start data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 3,
        title: Text(
          '   Daily Assessment',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.grey[100],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hasSmoke
                ? Container(
                    margin: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                    // height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: ListTile(
                      title: Column(
                        children: [
                          const Text(
                            'Have you smoked tobacco today?',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          if (hasSmokedTobacco) ...[
                            const SizedBox(height: 10.0),
                            const Text('******'),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Number of tobaccos smoked:',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              onChanged: (value) {
                                setState(() {
                                  tobaccoCount = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                      trailing: Checkbox(
                        value: hasSmokedTobacco,
                        onChanged: (value) {
                          setState(() {
                            hasSmokedTobacco = value!;
                            if (!value!) {
                              tobaccoCount =
                                  0; // Reset the count when unchecked
                            }
                          });
                        },
                      ),
                    ),
                  )
                : Container(),
            const SizedBox(height: 20.0),
            hasDrink
                ? Container(
                    margin: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                    // height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: ListTile(
                      title: Column(
                        children: [
                          const Text(
                            'Have you had a drink today?',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          if (hasHadDrink) ...[
                            const SizedBox(height: 10.0),
                            const Text('******'),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Number of drinks had:',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            TextFormField(
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              onChanged: (value) {
                                setState(() {
                                  drinkCount = int.tryParse(value) ?? 0;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                      trailing: Checkbox(
                        value: hasHadDrink,
                        onChanged: (value) {
                          setState(() {
                            hasHadDrink = value!;
                            if (!value!) {
                              drinkCount = 0; // Reset the count when unchecked
                            }
                          });
                        },
                      ),
                    ),
                  )
                : Container(),
            // SizedBox(height: 60.0),
            const Spacer(), // Add a spacer to push the button to the bottom

            Container(
              width: MediaQuery.of(context).size.width * .88,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                onPressed: () {
                  // Perform assessment logic here
                  print('Assessment result:');
                  print('Has smoked tobacco: $hasSmokedTobacco');
                  print('Tobacco count: $tobaccoCount');
                  print('Has had a drink: $hasHadDrink');
                  print('Drink count: $drinkCount');
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DailyAssessmentPage(
                      positiveDrink: !hasHadDrink,
                      positiveSmoke: !hasSmokedTobacco,
                      // smokeAddiction: ,
                      // drinkAddiction: null,
                      smokeStartDate: smokeDate, drinkStartDate: drinkDate,
                      smoke: hasSmoke, drink: hasDrink, hasReviewed: widget.hasReviewed,
                    ),
                  ));
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
