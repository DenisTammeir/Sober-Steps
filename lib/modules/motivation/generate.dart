import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreBatchAddPage extends StatefulWidget {
  @override
  _FirestoreBatchAddPageState createState() => _FirestoreBatchAddPageState();
}

class _FirestoreBatchAddPageState extends State<FirestoreBatchAddPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 DateTime _startDate = DateTime.now().add(Duration(days: 600));
DateTime _endDate = DateTime.now().add(Duration(days: 1000)); // One month later

// Update the dates dynamically
// _startDate = DateTime.now().add(Duration(days: 10)); // Update _startDate to 30 days from now
// _endDate = DateTime.now().add(Duration(days: 60)); // Update _endDate to 60 days from now


  List<String> messageList = [
    "Believe you can and you're halfway there.",
    "The only way to do great work is to love what you do.",
    "Push yourself, because no one else is going to do it for you.",
    "Success is not final, failure is not fatal: It is the courage to continue that counts.",
    "Hardships often prepare ordinary people for an extraordinary destiny.",
    "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "Don't watch the clock; do what it does. Keep going.",
    "The secret of getting ahead is getting started.",
    "You are never too old to set another goal or to dream a new dream.",
    "Our greatest glory is not in never falling, but in rising every time we fall.",
    "Quality is not an act, it is a habit.",
    "With the new day comes new strength and new thoughts.",
    "In the middle of every difficulty lies opportunity.",
    "What you get by achieving your goals is not as important as what you become by achieving your goals.",
    "The only way to achieve the impossible is to believe it is possible.",
    "Success is not the key to happiness. Happiness is the key to success. If you love what you are doing, you will be successful.",
    "Don't be pushed around by the fears in your mind. Be led by the dreams in your heart.",
    "It does not matter how slowly you go, as long as you do not stop.",
    "Do not wait to strike till the iron is hot, but make it hot by striking.",
    "Life is not about waiting for the storm to pass but learning to dance in the rain.",
    "Believe you can and you're halfway there.",
    "You have to be at your strongest when you're feeling at your weakest.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "The only way to do great work is to love what you do.",
    "If you want to achieve greatness stop asking for permission.",
    "If you are not willing to risk the usual you will have to settle for the ordinary.",
    "The harder you work for something, the greater you'll feel when you achieve it.",
    "Success is walking from failure to failure with no loss of enthusiasm.",
    "Don't be afraid to give up the good to go for the great.",
    "I find that the harder I work, the more luck I seem to have.",
    "Success is not the key to happiness. Happiness is the key to success. If you love what you are doing, you will be successful.",
    "In order to succeed, we must first believe that we can.",
    "If you don't build your dream, someone else will hire you to help them build theirs.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "What you get by achieving your goals is not as important as what you become by achieving your goals.",
    "If you want to achieve greatness stop asking for permission.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "What you get by achieving your goals is not as important as what you become by achieving your goals.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "What you get by achieving your goals is not as important as what you become by achieving your goals.",
    "You have to be at your strongest when you're feeling at your weakest.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "The only way to do great work is to love what you do.",
    "If you want to achieve greatness stop asking for permission.",
    "If you are not willing to risk the usual you will have to settle for the ordinary.",
    "The harder you work for something, the greater you'll feel when you achieve it.",
    "Success is walking from failure to failure with no loss of enthusiasm.",
    "Don't be afraid to give up the good to go for the great.",
    "I find that the harder I work, the more luck I seem to have.",
    "Success is not the key to happiness. Happiness is the key to success. If you love what you are doing, you will be successful.",
    "In order to succeed, we must first believe that we can.",
    "If you don't build your dream, someone else will hire you to help them build theirs.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "What you get by achieving your goals is not as important as what you become by achieving your goals.",
    "If you want to achieve greatness stop asking for permission.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "What you get by achieving your goals is not as important as what you become by achieving your goals.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "What you get by achieving your goals is not as important as what you become by achieving your goals.",
    "You have to be at your strongest when you're feeling at your weakest.",
    "The best time to plant a tree was 20 years ago. The second best time is now.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "The only way to do great work is to love what you do.",
    "If you want to achieve greatness stop asking for permission.",
    "If you are not willing to risk the usual you will have to settle for the ordinary.",
    "The harder you work for something, the greater you'll feel when you achieve it.",
    "Success is walking from failure to failure with no loss of enthusiasm.",
    "Don't be afraid to give up the good to go for the great.",
    "I find that the harder I work, the more luck I seem to have.",
    "Success is not the key to happiness. Happiness is the key to success. If you love what you are doing, you will be successful.",
    "In order to succeed, we must first believe that we can.",
    "If you don't build your dream, someone else will hire you to help them build theirs.",
    "The only limit to our realization of tomorrow will be our doubts of today.",
    "What you get by achieving your goals is not as important as what you become by achieving your goals.",
  ];

  String selectRandomMessage(List<String> messages) {
    // Generate a random index within the range of the list
    int randomIndex = Random().nextInt(messages.length);

    // Return the message at the randomly selected index
    return messages[randomIndex];
  }

  Future<void> _batchAddData() async {
    // Iterate over the dates within the range
    for (DateTime date = _startDate;
        date.isBefore(_endDate);
        date = date.add(Duration(days: 1))) {
      // Create a reference to the document with the date as the ID
      DocumentReference docRef = _firestore
          .collection('motivation')
          .doc(date.toString().substring(0, 10));
      // Select a random message for the current date
      String randomMessage = selectRandomMessage(messageList);

      // Create a DateTime object representing the start of the day for the current date
      DateTime startOfDay = DateTime(date.year, date.month, date.day);

      // Convert the DateTime object to a Timestamp object
      Timestamp timestamp = Timestamp.fromDate(startOfDay);

      // Create a batch and set the data for the document
      WriteBatch batch = _firestore.batch();
      batch.set(docRef, {
        'timestamp': timestamp,
        'message':
            randomMessage, // You can replace this with your actual message
      });

      // Commit the batch
      await batch.commit();
    }

    // Show a snackbar or toast to indicate the process is complete
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Batch data added successfully for the month!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Batch Add'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _batchAddData,
          child: Text('Add Batch Data'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Firestore Batch Add Example',
    home: FirestoreBatchAddPage(),
  ));
}
