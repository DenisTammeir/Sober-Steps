import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sober_steps/modules/motivation/generate.dart';
import 'package:sober_steps/modules/motivation/quotes.dart';

class MotivationalQuotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime previousDay = now.subtract(const Duration(days: 1));

    List<DateTime> daysList = [];
    while (previousDay.isAfter(firstDayOfMonth)) {
      daysList.add(previousDay);
      previousDay = previousDay.subtract(const Duration(days: 1));
    }

    Stream<DocumentSnapshot> getMessageStream(DateTime date) {
      // Create a document reference for the specified date
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('motivation')
          .doc(date.toString().substring(0, 10));

      // Return the snapshot stream of the document
      return docRef.snapshots();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 3,
        title: Text(
          '    Motivation',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            color: Colors.grey[100],
          ),
        ),
        // actions: [
        //     IconButton(
        //       onPressed: () {
        //         Navigator.of(context).push(MaterialPageRoute(
        //           builder: (context) => FirestoreBatchAddPage(),
        //         ));
        //       },
        //       icon: const Icon(
        //         Icons.add_box_outlined,
        //         size: 30,
        //         color: Colors.white,
        //       ))
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
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
            Container(
              margin: const EdgeInsets.fromLTRB(22, 40, 22, 20),
              child: Text(
                'Previous',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              itemCount: daysList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(22, 6, 22, 6),
                  height: 50,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: ListTile(
                    title: Text(
                        '${daysList[index].day} ${_getMonthName(daysList[index].month)}'),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => QuoteDaily(
                          quoteDate: daysList[index],
                        ),
                      ));
                    },
                    // Add more content or customization as needed
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
