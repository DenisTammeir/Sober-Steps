import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/modules/sos/add_sos.dart';
import 'package:url_launcher/url_launcher.dart';

class SOS extends StatefulWidget {
  const SOS({super.key});

  @override
  State<SOS> createState() => _SOSState();
}

class _SOSState extends State<SOS> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              // onTap: () {
              //   Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => AddSOS(),
              //   ));
              // },
              child: Text(
                ' SOS ',
                style: TextStyle(
                    color: Colors.grey[700],
                    // fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * .64,
              height: 40,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              // margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    searchText = value
                        .toLowerCase(); // Update the searchText on text changes
                  });
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'search...',
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 63, 62, 62),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100], // Setting grey color
                  border: OutlineInputBorder(
                    // Define the border
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none, // No side border
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Define the border for the enabled state
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none, // No side border
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Define the border for the focused state
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none, // No side border
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sos')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No sos...'));
          }
          final sosDoc = snapshot.data!.docs;

             final List sosDocs =
                              sosDoc.where((sos) {
                            final username = sos['name'].toLowerCase();
                            final searchQuery = searchText.toLowerCase();
                            return username.contains(searchQuery);
                          }).toList();


          return ListView.builder(
            itemCount: sosDocs.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {

              final sos =
                    sosDocs[index].data() as Map<String, dynamic>;

                final name = sos['name'] as String;
                final phone = sos['phone'] as String;
             
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color.fromARGB(255, 2, 247, 255).withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                // color: Theme.of(context).hintColor,
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: ListTile(
                  onTap: () async{
                      final Uri params = Uri(
                                        scheme: 'tel',
                                        path: phone,
                                      );
                                      final String phoneurl = params.toString();
                                      if (await canLaunch(phoneurl)) {
                                        await launch(phoneurl);
                                      } else {
                                        throw 'Sorry cannot launch $phoneurl';
                                      }
                                    
                                 
                  },
                  leading: Container(
                    width:
                        40, // Adjust the size of the circle as per your requirement
                    height:
                        40, // Adjust the size of the circle as per your requirement
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // You can change the color of the circle here
                    ),
                    child: Icon(
                      Icons.call,
                      color: Theme.of(context)
                          .colorScheme
                          .primary, // You can change the color of the icon here
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          name,
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                        child: Text(
                          phone,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }
}
