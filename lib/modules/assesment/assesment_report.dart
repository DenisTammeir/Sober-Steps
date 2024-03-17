import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MotivationalQuotesPage extends StatelessWidget {
  final String mood;
  final bool positiveDrink;
  final bool positiveSmoke;
  final bool drink;
  final bool smoke;
  final smokeStartDate;
  final drinkStartDate;

  MotivationalQuotesPage({
    required this.mood,
    required this.positiveDrink,
    required this.positiveSmoke,
    required this.smokeStartDate,
    required this.drinkStartDate,
    required this.drink,
    required this.smoke,
  });

  @override
  Widget build(BuildContext context) {
    String motivationalQuote = '';
    final user = FirebaseAuth.instance.currentUser;
    final _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    switch (mood) {
      case 'Very Sad':
        motivationalQuote = (positiveDrink && positiveSmoke)
            ? 'Even in tough times, remember to take care of yourself.'
            : 'Seek support from loved ones. You are not alone.';
        break;
      case 'Sad':
        motivationalQuote = (positiveDrink && positiveSmoke)
            ? 'Challenges are opportunities in disguise. Stay strong!'
            : 'Believe in yourself. You are capable of great things.';
        break;
      case 'Neutral':
        motivationalQuote = (positiveDrink && positiveSmoke)
            ? 'Take time to rest and recharge. Self-care is important.'
            : 'Stay positive. You have the power to change your path.';
        break;
      case 'Happy':
        motivationalQuote = (positiveDrink && positiveSmoke)
            ? 'You are capable of achieving your goals. Keep believing!'
            : 'Visualize success and work towards it. You got this!';
        break;
      case 'Very Happy':
        motivationalQuote = (positiveDrink && positiveSmoke)
            ? 'Celebrate your victories, big or small. You are doing great!'
            : 'Your positive choices today shape your future. Keep making them!';
        break;
      default:
        motivationalQuote = 'No motivational quote available.';
    }

    return Scaffold(
      appBar: AppBar(
         backgroundColor: Theme.of(context).colorScheme.background,
         elevation: 3,
         title: Text('   Daily Assessment',
         style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[100],
                  ),
        ),
      ),
      body: Center(
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
                height: 300,
                child: Card(
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(
                        //   'Motivational Quote',
                        //   style: TextStyle(
                        //     fontSize: 16.0,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        Text(
                          'Mood: $mood',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        SizedBox(
                          height: 160,
                          child: Center(
                            child: Text(
                              motivationalQuote,
                              style: TextStyle(
                                fontSize: 14.0,
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
                                backgroundColor:
                                    const Color.fromARGB(255, 206, 242, 247),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            onPressed: () async {
                              // Perform assessment logic here

                              // Navigator.of(context).push(MaterialPageRoute(
                              //   builder: (context) => DailyAssessmentPage(
                              //     positiveDrink: !hasHadDrink,
                              //     positiveSmoke: !hasSmokedTobacco,
                              //   ),
                              // ));

                              FirebaseFirestore firestore =
                                  FirebaseFirestore.instance;

                              // Get the collection reference
                              CollectionReference collectionRef =
                                  firestore.collection('assesments');

                              // Add data to the collection
                              DocumentReference documentRef =
                                  await collectionRef.add({
                                'userid': user?.uid,
                                'timestamp': FieldValue.serverTimestamp(),
                                'quote': motivationalQuote,
                                'mood': mood,
                                'drink': !positiveDrink,
                                'smoke': !positiveSmoke,
                                // 'value': randomValue,
                              });

                              // Update the document to add the ID field
                              await documentRef.update({'id': documentRef.id});

                              List<Map<String, dynamic>> addictionList = [];
                              if (!positiveDrink) {
                                addictionList.add({
                                  'addiction': 'Alcohol',
                                  'start_date': DateTime.now(),
                                });
                                // if (smoke && positiveSmoke) {
                                //   addictionList.add({
                                //     'addiction': 'Smoking',
                                //     'start_date': smokeStartDate,
                                //   });
                                // }
                              } else if (drink) {
                                addictionList.add({
                                  'addiction': 'Alcohol',
                                  'start_date': drinkStartDate,
                                });
                              }
                              if (!positiveSmoke) {
                                addictionList.add({
                                  'addiction': 'Smoking',
                                  'start_date': DateTime.now(),
                                });
                                // if (drink && positiveDrink) {
                                //   addictionList.add({
                                //     'addiction': 'Alcohol',
                                //     'start_date': drinkStartDate,
                                //   });
                                // }
                              } else if (smoke) {
                                addictionList.add({
                                  'addiction': 'Smoking',
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
                              Navigator.of(context).pop();
                               Navigator.of(context).pop();
                                Navigator.of(context).pop();
                            },
                            child: Text(
                              'Complete Assesment',
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
    );
  }
}
