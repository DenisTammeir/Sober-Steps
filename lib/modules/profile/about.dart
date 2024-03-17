import 'package:flutter/material.dart';
import 'package:sober_steps/utils/watermark.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Watermark Text
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: WatermarkPainter(),
            ),
          ),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * .84,
            height: MediaQuery.of(context).size.height * .8,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              children: [
                Text(
                  'Sober Steps',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          'Our application is a comprehensive platform for individuals recovering from drug addiction, including alcohol and smoking dependencies. It provides personalized support through goal-setting, mentorship, and daily motivational quotes. Users receive guidance from experienced mentors, access assessment tools to track progress, and join online communities for peer support. In emergencies, immediate help is available through crisis intervention services and helplines. Educational resources cover addiction science, recovery strategies, and relapse prevention. The app delivers personalized recommendations based on user preferences and usage patterns. We emphasize community, empathy, and human connection, fostering a supportive environment where users can heal and thrive. Our goal is to empower individuals on their recovery journey, providing hope, solidarity, and the tools needed to overcome addiction and embrace a brighter future. Join us in building a healthier, more resilient community together.',
                          //  overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 14.0,
                            // fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
