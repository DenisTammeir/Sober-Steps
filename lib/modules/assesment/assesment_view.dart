import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssesmentView extends StatelessWidget {
  final quote;
  final date;
  final mood;
  const AssesmentView(
      {super.key, required this.quote, required this.date, required this.mood});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Motivational Quote'),
      // ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      'assets/mount.jpeg'), // Replace 'assets/background_image.jpg' with your image path
                  fit: BoxFit
                      .cover, // Adjust the BoxFit according to your requirement
                  opacity: .8),
            ),
            // Other container properties like width, height, child, etc.
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
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
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 250,
                    child: Card(
                      elevation: 3.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Mood: $mood',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                     color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '${DateFormat.E().format(date!)}, ${DateFormat.MMMd().format(date)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                              height: 160,
                              child: Center(
                                child: Text(
                                  quote,
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ),
                            // Container(
                            //   width: MediaQuery.of(context).size.width * .88,
                            //   height: 50,
                            //   child: ElevatedButton(
                            //     style: ElevatedButton.styleFrom(
                            //         elevation: 4,
                            //         backgroundColor: const Color.fromARGB(
                            //             255, 206, 242, 247),
                            //         shape: const RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.all(
                            //                 Radius.circular(10)))),
                            //     onPressed: () async {
                            //       // Perform assessment logic here

                            //       // Navigator.of(context).push(MaterialPageRoute(
                            //       //   builder: (context) => DailyAssessmentPage(
                            //       //     positiveDrink: !hasHadDrink,
                            //       //     positiveSmoke: !hasSmokedTobacco,
                            //       //   ),
                            //       // ));

                            //       // FirebaseFirestore firestore =
                            //       //     FirebaseFirestore.instance;

                            //       // // Get the collection reference
                            //       // CollectionReference collectionRef =
                            //       //     firestore.collection('assesments');

                            //       // // Add data to the collection
                            //       // DocumentReference documentRef =
                            //       //     await collectionRef.add({
                            //       //   'userid': user?.uid,
                            //       //   'timestamp': FieldValue.serverTimestamp(),
                            //       //   'quote': motivationalQuote,
                            //       //   'mood': mood,
                            //       //   'drink': !positiveDrink,
                            //       //   'smoke': !positiveSmoke,
                            //       // 'value': randomValue,
                            //       // });

                            //       // Update the document to add the ID field
                            //       // await documentRef.update({'id': documentRef.id});
                            //       Navigator.of(context).pop();
                            //     },
                            //     child: Text(
                            //       'Review',
                            //       style: TextStyle(
                            //         color: Colors.grey[700],
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
}
