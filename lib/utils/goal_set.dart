import 'package:flutter/material.dart';

class GoalListItem extends StatelessWidget {
  final String goalText;
  final bool isAchieved;
  final Function(bool?)? onChanged;

  GoalListItem({
    required this.goalText,
    required this.isAchieved,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      title: Text(
        goalText,
        style: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: Checkbox(
        value: isAchieved,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
      tileColor: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      onTap: () {
        // Add any functionality for tapping the ListTile
      },
    );
  }
}
