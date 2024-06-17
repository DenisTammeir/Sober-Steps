import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sober_steps/modules/goals/goal_add.dart';
import 'package:sober_steps/modules/goals/goals.dart';

class DaysListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
         backgroundColor: Theme.of(context).colorScheme.background,
        //  elevation: 3,
         title: Text('   Goals',
         style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[100],
                  ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddGoalPage(),
                ));
              },
              icon: const Icon(
                Icons.add_task_outlined,
                size: 36,
                color: Colors.white,
              )),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: DaysList(),
    );
  }
}

class DaysList extends StatelessWidget {
  final int yearsToDisplay = 1;

  @override
  Widget build(BuildContext context) {
    Map<String, List<DateTime>> daysByMonth = {};

    DateTime currentDate = DateTime.now();
    DateTime startDate = DateTime(currentDate.year - yearsToDisplay,
        currentDate.month, currentDate.day + 2);

    for (int i = 0; i < yearsToDisplay * 365; i++) {
      DateTime date = startDate.add(Duration(days: i));
      String month = DateFormat('MMMM yyyy').format(date);

      if (!daysByMonth.containsKey(month)) {
        daysByMonth[month] = [];
      }

      daysByMonth[month]!.add(date);
    }

    // Reverse the order of months
    List<String> months = daysByMonth.keys.toList();
    months = months.reversed.toList();

    // Reverse the order of days within each month
    daysByMonth.forEach((key, value) {
      value = value.reversed.toList();
      daysByMonth[key] = value;
    });

    return ListView.builder(
      itemCount: months.length,
      itemBuilder: (context, index) {
        String month = months[index];
        List<DateTime> days = daysByMonth[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 24,
              ),
              child: Text(
                month,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Column(
              children: days.map((date) => DayTile(date: date)).toList(),
            ),
          ],
        );
      },
    );
  }
}

class DayTile extends StatelessWidget {
  final DateTime date;

  DayTile({required this.date});

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = DateFormat('EEEE').format(date);
    String formattedDate = DateFormat('d').format(date);

     String dayOWeek = DateFormat('EEE').format(date);
    String month = DateFormat('MMM').format(date);


    return Container(
      margin: const EdgeInsets.fromLTRB(22, 3, 22, 3),
      height: 46,
      decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: ListTile(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ViewGoals(
            date: date, formatedDate: '$dayOWeek, $formattedDate $month',
          ),
        )),
        title: Row(
          children: [
            Text(
              '$dayOfWeek ',
              style: const TextStyle(fontSize: 13
                  // fontWeight: FontWeight.bold,
                  // color: Colors.white,
                  ),
            ),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 13
                  // fontWeight: FontWeight.bold,
                  // color: Colors.white,
                  ),
            ),
          ],
        ),
        // subtitle: Text(formattedDate),
        // tileColor: Colors.blue[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
}
