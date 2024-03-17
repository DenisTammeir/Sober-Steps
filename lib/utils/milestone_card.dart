import 'package:flutter/material.dart';

class MilestoneCard extends StatelessWidget {
  // final String title;
  // final String description;
  final int daysSober; // Number of days sober

  MilestoneCard({required this.daysSober});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: daysSober >= 10 ? 10 : daysSober,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // Calculate the day to display (starting from the latest)
          int day = daysSober - index;
          int lastDigit = day % 10;
          // Determine the description based on the last digit
          String description = '';
          switch (lastDigit) {
            case 0:
              description = 'You are on your way!';
              break;
            case 1:
              description = 'Keep it up!';
              break;
            case 2:
              description = 'You are doing great!';
              break;
            case 3:
              description = 'Stay strong!';
              break;
            case 4:
              description = 'You got this!';
              break;
            case 5:
              description = 'Almost there!';
              break;
            case 6:
              description = 'One day at a time!';
              break;
            case 7:
              description = 'You are unstoppable!';
              break;
            case 8:
              description = 'Keep pushing forward!';
              break;
            case 9:
              description = 'You are amazing!';
              break;
            default:
              description = '';
          }

          return Container(
            padding: EdgeInsets.all(16.0),
            margin: EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Day $day',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Text(
                    //   '$daysSober', // Display the number of days sober
                    //   style: TextStyle(
                    //     fontSize: 16.0,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    SizedBox(width: 4.0),
                    Icon(
                      Icons.emoji_events, // Trophy icon
                      color: Colors.yellow[700],
                      size: 36,
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
