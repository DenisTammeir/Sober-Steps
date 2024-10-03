import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/modules/assesment/assesment_list.dart';

import 'package:sober_steps/modules/soberity/soberity_update.dart';
import 'package:sober_steps/modules/widgets/bottom_bar.dart';
import 'package:sober_steps/utils/milestone_container.dart';
import 'package:sober_steps/utils/reviews.dart';
import 'package:sober_steps/utils/timer.dart';

class Home extends StatefulWidget {
  final indece;
  const Home({
    super.key,
    this.indece,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Duration _duration = Duration(seconds: 0);
  // Timer? _timer;
  // final _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   // Update duration every second
  //   _timer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     setState(() {
  //       _duration += Duration(seconds: 1);
  //     });
  //   });
  // }

  // @override
  // void dispose() {
  //   _timer?.cancel();
  //   super.dispose();
  // }

  late DateTime _startDate = DateTime.now();
  late Duration _duration = Duration.zero; // Initialize with default value
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Timer _timer;
  var addiction;
  int indece = 0; // Specify the index you want to use

  @override
  void initState() {
    super.initState();
    // Fetch the start date from Firebase Firestore
    fetchStartDate().then((value) => _startTimer());
    // Start the timer to update the duration every second
  }

  Future<void> fetchStartDate() async {
    if (widget.indece != null) {
      setState(() {
        indece = widget.indece;
      });
    }
    // Fetch the user's data from Firebase Firestore
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('sobriety')
        .doc(_auth.currentUser!.uid)
        .get();

    if (snapshot.exists) {
      // Get the data as a Map<String, dynamic>
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      // Check if data is not null and contains the 'addictions' key
      if (data != null && data.containsKey('addictions')) {
        // Get the list of addictions
        List<dynamic>? addictions = data['addictions'];

        setState(() {
          addiction = addictions;
        });

        // Check if addictions is not null and not empty
        if (addictions != null && addictions.isNotEmpty) {
          if (indece >= 0 && indece < addictions.length) {
            // Get the addiction at the specified index
            var addiction = addictions[indece];
            // Check if the addiction has a start date
            if (addiction['start_date'] != null) {
              // Set the start date
              _startDate = addiction['start_date'].toDate();
              // Calculate the duration between the start date and the current date
              // _duration = DateTime.now().difference(_startDate);
              // Update the UI
              setState(() {});
            }
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Calculate the duration between the start date and the current time
      _duration = DateTime.now().difference(_startDate);
      setState(() {}); // Update the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: Builder(
          builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.menu,
                size: 30,
                color: Colors.white,
              )),
        ),
        title: addiction == null
            ? const Text(
                'Dredging...',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              )
            : Text(
                addiction[indece]['addiction'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AssessmentHistoryPage(),
                ));
              },
              icon: const Icon(
                Icons.add_box_outlined,
                size: 30,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        // padding: const EdgeInsets.all(20.0),
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),

                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40),
                            )),
                        // height: MediaQuery.of(context).size.height - 400,
                        child: Column(
                          children: [
                            // Positioned(child:
                            const Reviews(),
                            const SizedBox(
                              height: 30,
                            ),
                            // ),
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TimeProgressBar(
                                    label: 'Years',
                                    duration: _duration.inDays ~/ 365,
                                    maxDuration: 40, // Maximum duration (years)
                                    color: Colors.red,
                                  ),
                                  TimeProgressBar(
                                    label: 'Months',
                                    duration: _duration.inDays % 365 ~/ 30,
                                    maxDuration:
                                        12, // Maximum duration (months)
                                    color: Colors.blue,
                                  ),
                                  TimeProgressBar(
                                    label: 'Days',
                                    duration: _duration.inDays % 30,
                                    maxDuration: 30, // Maximum duration (days)
                                    color: Colors.green,
                                  ),
                                  TimeProgressBar(
                                    label: 'Hours',
                                    duration: _duration.inHours % 24,
                                    maxDuration: 24, // Maximum duration (hours)
                                    color: Colors.orange,
                                  ),
                                  TimeProgressBar(
                                    label: 'Minutes',
                                    duration: _duration.inMinutes % 60,
                                    maxDuration:
                                        60, // Maximum duration (minutes)
                                    color: Colors.purple,
                                  ),
                                  TimeProgressBar(
                                    label: 'Seconds',
                                    duration: _duration.inSeconds % 60,
                                    maxDuration:
                                        60, // Maximum duration (seconds)
                                    color: Colors.yellow,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: MilestoneContainer(
                      duration: _duration,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 2 / 3,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.zero)),
        backgroundColor: Theme.of(context).colorScheme.background,
        child: addiction == null
            ? const Center(child: Text('No addictions found.'))
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    height: 25,
                    color: Colors.grey,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addiction.length,
                    itemBuilder: (context, index) {
                      var addiction_data = addiction[index]['addiction'];
                      var startDate =
                          (addiction[index]['start_date'] as Timestamp)
                              .toDate();
                      var currentDate = DateTime.now();
                      var difference = currentDate.difference(startDate);

                      var years = difference.inDays ~/ 365;
                      var months = (difference.inDays % 365) ~/ 30;
                      var days = difference.inDays % 30;

                      String timePassed = '';

                      if (years > 0) {
                        timePassed +=
                            '$years ${years == 1 ? 'year' : 'years'} ';
                      }

                      if (months > 0) {
                        timePassed +=
                            '$months ${months == 1 ? 'month' : 'months'} ';
                      }

                      if (days > 0) {
                        timePassed += '$days ${days == 1 ? 'day' : 'days'} ';
                      }

// Remove trailing space
                      timePassed = timePassed.trim();

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: Colors.grey[200],
                          child: ListTile(
                            title: Text(
                              addiction_data,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Last: ${timePassed.toString()}'),
                            // Add onTap function if needed
                            onTap: () {
                              setState(() {
                                indece = index;
                              });
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BottomBar(
                                  indece: index,
                                ),
                              ));
                              // Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                            style: BorderStyle.solid),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12))),
                    child: IconButton(
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SobrietyUpdatePage(),
                            )),
                        icon:  Icon(
                          Icons.edit_calendar_outlined,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                  )
                ],
              ),
      ),
    );
  }
}
