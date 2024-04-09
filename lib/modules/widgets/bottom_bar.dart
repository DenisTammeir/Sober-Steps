import 'package:flutter/material.dart';
import 'package:sober_steps/modules/communities/community_tab.dart';
import 'package:sober_steps/modules/goals/goal_days.dart';
import 'package:sober_steps/modules/homepage/home.dart';
import 'package:sober_steps/modules/motivation/quote_view.dart';
import 'package:sober_steps/modules/profile/about.dart';
import 'package:sober_steps/modules/profile/profile.dart';
// import 'Home';

class BottomBar extends StatefulWidget {
  final indece;

  const BottomBar({super.key, this.indece});
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Home(
        indece: widget.indece,
      ),
      // ViewGoals(),
      DaysListScreen(),
      CommunityTab(),
      MotivationalQuotesPage(),
      // AssessmentPage(),
      ProfilePage(),
    ];
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Bottom Bar with Elevated Middle Item'),
      // ),
      bottomNavigationBar: BottomAppBar(
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.task_alt_outlined),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.people_outline_outlined),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                // InkWell(
                //   onTap: () => Navigator.of(context).push(MaterialPageRoute(
                //     builder: (context) => About(),
                //   )),
                //   child: Container(
                //     width: 25,
                //     // color: Colors.blue,
                //     child: Text(
                //       'Sober\nSteps',
                //       style:
                //           TextStyle(fontSize: 6, fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // ), // Spacer for the middle item
                IconButton(
                  icon: const Icon(Icons.energy_savings_leaf_outlined),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 4;
                    });
                  },
                ),
              ],
            ),
            // Positioned(
            //   bottom: 0,
            //   left: MediaQuery.of(context).size.width *.5 - 35,
            //   child: CircleAvatar(
            //     radius: 35,
            //     backgroundColor: Colors.blue,
            //   ),
            // )
          ],
        ),
      ),

      body: _pages[_selectedIndex],
    );
  }
}
