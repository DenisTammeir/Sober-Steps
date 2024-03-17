import 'package:flutter/material.dart';
import 'package:sober_steps/modules/assesment/assesment_report.dart';

class DailyAssessmentPage extends StatefulWidget {
  final bool positiveDrink;
  final bool positiveSmoke;
  final smoke;
  final drink;
  final smokeStartDate;
  final drinkStartDate;

  const DailyAssessmentPage(
      {super.key, required this.positiveDrink, required this.positiveSmoke,   required this.smokeStartDate, required this.drinkStartDate, required this.smoke, required this.drink});
  @override
  _DailyAssessmentPageState createState() => _DailyAssessmentPageState();
}

class _DailyAssessmentPageState extends State<DailyAssessmentPage> {
  int _selectedRating = -1;
  final List<String> _emojis = ['😞', '😕', '😐', '🙂', '😊'];
  final List<String> _emojiDescriptions = [
    'Very Sad',
    'Sad',
    'Neutral',
    'Happy',
    'Very Happy'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
         elevation: 3,
         title: Text('   Mood Assessment',
         style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[100],
                  ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How do you feel today?',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _emojis
                  .asMap()
                  .entries
                  .map(
                    (entry) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = entry.key;
                        });
                      },
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: _selectedRating == entry.key
                              ? Colors.blue
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Center(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 30.0,
                              color: _selectedRating == entry.key
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 40.0),
            const Spacer(), // Add a spacer to push the button to the bottom
            SizedBox(
              width: MediaQuery.of(context).size.width * .88,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                onPressed: () {
                  // Perform action on button press
                  if (_selectedRating != -1) {
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return AlertDialog(
                    //       title: const Text('Assessment Result'),
                    //       content: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Text(
                    //             'You selected: ${_emojis[_selectedRating]}',
                    //           ),
                    //           const SizedBox(height: 10.0),
                    //           Text(
                    //             'Description: ${_emojiDescriptions[_selectedRating]}',
                    //           ),
                    //         ],
                    //       ),
                    //       actions: [
                    //         TextButton(
                    //           onPressed: () {
                    //             Navigator.of(context).pop();
                    //           },
                    //           child: const Text('OK'),
                    //         ),
                    //       ],
                    //     );
                    //   },
                    // );
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MotivationalQuotesPage(
                        mood: '${_emojiDescriptions[_selectedRating]}',
                        positiveDrink: widget.positiveDrink,
                        positiveSmoke: widget.positiveSmoke, smokeStartDate: widget.smokeStartDate, drinkStartDate: widget.drinkStartDate, drink: widget.drink, smoke: widget.smoke,
                      ),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a rating.'),
                      ),
                    );
                  }
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
