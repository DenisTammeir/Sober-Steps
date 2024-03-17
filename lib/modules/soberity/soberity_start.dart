import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sober_steps/modules/widgets/bottom_bar.dart';

class SobrietyStartPage extends StatefulWidget {
  @override
  _SobrietyStartPageState createState() => _SobrietyStartPageState();
}

class _SobrietyStartPageState extends State<SobrietyStartPage> {
  String? drinkAddiction;
  String? smokeAddiction;
  DateTime? drinkStartDate;
  DateTime? smokeStartDate;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                 backgroundColor: Theme.of(context).colorScheme.background,
         elevation: 3,
        title: Text('    Soberity Start',
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
            Text(
              'Select Your Addiction(s):',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            CheckboxListTile(
              title: Text('Alcohol'),
              value: drinkAddiction != null,
              onChanged: (value) {
                setState(() {
                  drinkAddiction = value! ? 'Alcohol' : null;
                });
              },
            ),
            CheckboxListTile(
              title: Text('Smoking'),
              value: smokeAddiction != null,
              onChanged: (value) {
                setState(() {
                  smokeAddiction = value! ? 'Smoking' : null;
                });
              },
            ),
            SizedBox(height: 16.0),
            if (drinkAddiction != null) ...[
              Text(
                'Select Alcohol Abstinence  Start Date:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
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
              Text(
                'Select  Smoking Abstinence Start Date:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
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
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                if ((drinkAddiction != null && drinkStartDate != null) ||
                    (smokeAddiction != null && smokeStartDate != null)) {
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
                    await _firestore.collection('sobriety').doc(_auth.currentUser!.uid).set({
                      'uid': _auth.currentUser!.uid,
                      'addictions': addictionList,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Sobriety start data added to Firebase!')),
                    );
                     Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) =>  BottomBar()));
                  } catch (e) {
                    print('Error adding sobriety start data: $e');
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Please select addiction and start date.')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
