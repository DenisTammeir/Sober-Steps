import 'package:flutter/material.dart';

class TimeProgressBar extends StatelessWidget {
  final String label;
  final int duration;
  final int maxDuration;
  final Color color;

  const TimeProgressBar({
    Key? key,
    required this.label,
    required this.duration,
    required this.maxDuration,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                      topRight: Radius.circular(6.0),
                      bottomRight: Radius.circular(50.0),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: duration / maxDuration,

                  //  widthFactor: duration != null && maxDuration != null ? (duration - 10) / maxDuration : 0.0,
                  child: Container(
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      bottomLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                      bottomRight: Radius.circular(50.0),
                    ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Container(
                    alignment: Alignment.center,
                    height: 44.0,
                    width: 110.0,
                    padding: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, color],
                        stops: [
                          0.7,
                          1.0
                        ], // Stops for the gradient (0.8 means 80% from the left)
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(6.0),
                        bottomRight: Radius.circular(50.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '$label: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            fontSize: 12.0,
                          ),
                        ),
                        Text(
                          '$duration',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
