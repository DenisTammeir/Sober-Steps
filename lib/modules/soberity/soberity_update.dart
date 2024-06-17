// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sober_steps/modules/widgets/bottom_bar.dart';

class SobrietyUpdatePage extends StatefulWidget {
  @override
  _SobrietyUpdatePageState createState() => _SobrietyUpdatePageState();
}

class _SobrietyUpdatePageState extends State<SobrietyUpdatePage> {
  String? drinkAddiction;
  String? smokeAddiction;
  DateTime? drinkStartDate;
  DateTime? smokeStartDate;

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

          // Loop through each addiction entry
          for (var addictionEntry in addictions!) {
            var addiction = addictionEntry['addiction'];
            var startDate = addictionEntry['start_date'].toDate();

            // Check the type of addiction and update state variables accordingly
            if (addiction == 'Alcohol') {
              setState(() {
                drinkAddiction = addiction;
                drinkStartDate = startDate;
              });
            } else if (addiction == 'Smoking') {
              setState(() {
                smokeAddiction = addiction;
                smokeStartDate = startDate;
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
          '    Soberity Update',
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
            const Text(
              'Select Your Addiction(s):',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            CheckboxListTile(
              title: const Text('Alcohol'),
              value: drinkAddiction != null,
              onChanged: (value) {
                setState(() {
                  drinkAddiction = value! ? 'Alcohol' : null;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Smoking'),
              value: smokeAddiction != null,
              onChanged: (value) {
                setState(() {
                  smokeAddiction = value! ? 'Smoking' : null;
                });
              },
            ),
            const SizedBox(height: 16.0),
            if (drinkAddiction != null) ...[
              const Text(
                'Select Alcohol Abstinence  Start Date:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  setState(() {
                    drinkStartDate = selectedDate;
                  });
                },
                child: Text(
                  drinkStartDate != null
                      ? 'Selected: ${drinkStartDate!.toString().substring(0, 10)}'
                      : 'Select Date',
                ),
              ),
            ],
            if (smokeAddiction != null) ...[
              const Text(
                'Select  Smoking Abstinence Start Date:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  setState(() {
                    smokeStartDate = selectedDate;
                  });
                },
                child: Text(
                  smokeStartDate != null
                      ? 'Selected: ${smokeStartDate!.toString().substring(0, 10)}'
                      : 'Select Date',
                ),
              ),
            ],
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                if (
                    // Case 1: Both addictions are non-null with non-null dates
                    (drinkAddiction != null &&
                            drinkStartDate != null &&
                            smokeAddiction != null &&
                            smokeStartDate != null) ||
                        // Case 2: Only one addiction is non-null with a non-null date
                        ((drinkAddiction != null && drinkStartDate != null) &&
                            (smokeAddiction == null &&
                                smokeStartDate == null)) ||
                        ((smokeAddiction != null && smokeStartDate != null) &&
                            (drinkAddiction == null &&
                                drinkStartDate == null))) {
                  try {
                    List<Map<String, dynamic>> addictionList = [];
                    if (drinkAddiction != null) {
                      addictionList.add({
                        'addiction': drinkAddiction,
                        'start_date': drinkStartDate,
                      });
                    }
                    if (smokeAddiction != null) {
                      addictionList.add({
                        'addiction': smokeAddiction,
                        'start_date': smokeStartDate,
                      });
                    }
                    await _firestore
                        .collection('sobriety')
                        .doc(_auth.currentUser!.uid)
                        .update({
                      // 'uid': _auth.currentUser!.uid,
                      'addictions': addictionList,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Sobriety start data added to Firebase!')),
                    );
                    // Navigate back to the previous screen
                    // Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const BottomBar()));
                  } catch (e) {
                    print('Error adding sobriety start data: $e');
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please select addiction and start date.')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
