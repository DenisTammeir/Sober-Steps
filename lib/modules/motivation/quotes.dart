import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sober_steps/utils/watermark.dart';

class QuoteDaily extends StatelessWidget {
  final quoteDate;
  const QuoteDaily({super.key, required this.quoteDate});

  Stream<DocumentSnapshot> getMessageStream(DateTime date) {
    // Create a document reference for the specified date
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('motivation')
        .doc(quoteDate.toString().substring(0, 10));

    // Return the snapshot stream of the document
    return docRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: WatermarkPainter(),
              ),
            ),
          ),
          Center(
            child: Container(
              height: 300,
              margin: const EdgeInsets.fromLTRB(10, 50, 10, 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                image: DecorationImage(
                  image: AssetImage('assets/nature.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image.asset(
                  //   'assets/nature.jpg',
                  //   fit: BoxFit.cover,
                  // ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(14)),
                        color: Colors.black
                            .withOpacity(0.6), // Adjust opacity as needed
                      ),
                    ),
                  ),
                  // Use StreamBuilder to get the message for today's date
                  StreamBuilder<DocumentSnapshot>(
                      stream: getMessageStream(DateTime.now()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Show a loading indicator while waiting for data
                          return const Center();
                        } else if (snapshot.hasError) {
                          // Handle any errors
                          return Text('Error: ${snapshot.error}');
                        }
                        // Extract the message from the document snapshot
                        // Map<String, dynamic> data =
                        //     snapshot.data as Map<String, dynamic>;
                        var data = snapshot.data!.data() as Map<String,
                            dynamic>?; // Cast to Map<String, dynamic> or null
                        var message = data?['message'] ??
                            'Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine.';
                        var timestamp = data?['timestamp'] ??
                            Timestamp.fromDate(DateTime.now());
                        // Convert Timestamp to DateTime
                        DateTime date = timestamp.toDate();

                        String dayOWeek = DateFormat('d').format(date);
                        String month = DateFormat('MMM').format(date);
                        String formattedDate = '$month $dayOWeek';

                        // Display the message
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    '$formattedDate,\n',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  message,
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
