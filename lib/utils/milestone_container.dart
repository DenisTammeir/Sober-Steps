import 'package:flutter/material.dart';
import 'package:sober_steps/utils/milestone_card.dart';

class MilestoneContainer extends StatelessWidget {
  final duration;

  const MilestoneContainer({super.key, this.duration});

  @override
  Widget build(BuildContext context) {
    var time = duration.inDays;
    return Container(
      padding: EdgeInsets.all(20.0),
      margin: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          Container(
            child: const Text(
              'Milestone',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          // Image.asset(
          //   'assets/sober.png',
          //   width: 100,
          //   height: 100,
          // ),
          SizedBox(height: 20.0),
          MilestoneCard(
            // title: 'Day $time',
            // description: 'You are on your way!',
            daysSober: time,
          ),

          // MilestoneCard(
          //   title: 'Milestone 2',
          //   description: 'Description of Milestone 2',
          // ),
          // Add more MilestoneCard widgets as needed
        ],
      ),
    );
  }
}
