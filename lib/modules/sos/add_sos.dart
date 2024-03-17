import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSOS extends StatelessWidget {
  const AddSOS({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController();
    final phone = TextEditingController();
    return Scaffold(
      body: Center(
        child: Container(
          height: 400,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(8.0, 20.0, 8.0, 20.0),
                child: TextFormField(
                  controller: name,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    label: const Text('name...'),
                    contentPadding: const EdgeInsets.fromLTRB(6, 20, 6, 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    labelStyle: TextStyle(color: Colors.blue, fontSize: 11),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(8.0, 20.0, 8.0, 20.0),
                child: TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    label: const Text('phone...'),
                    contentPadding: const EdgeInsets.fromLTRB(6, 20, 6, 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    labelStyle: TextStyle(color: Colors.blue, fontSize: 11),
                  ),
                ),
              ),
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width * .88,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          // Use the theme color based on the current state
                          // final themeColor =
                          //     Theme.of(context).colorScheme.background;
                          const themeColor = Colors.purple;

                          // You can replace the following line with your actual theme color property
                          // final themeColor = Provider.of<ThemeProvider>(context).getButtonColor();

                          if (states.contains(MaterialState.pressed)) {
                            // Return the pressed color if the button is pressed
                            return themeColor.withOpacity(0.5);
                          }

                          // Return the default color for the button
                          return themeColor;
                        },
                      ),
                      // backgroundColor: SasaTheme.of(context).primaryText,
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the border radius as desired
                        ),
                      ),
                    ),
                    onPressed: () async {
                      // Get a Firestore instance
                      FirebaseFirestore firestore = FirebaseFirestore.instance;

                      // Get the collection reference
                      CollectionReference collectionRef =
                          firestore.collection('sos');

                      // Add data to the collection
                      DocumentReference documentRef = await collectionRef.add({
                        // 'userid': user?.uid,
                        'name': name.text.trim(),
                        'timestamp': FieldValue.serverTimestamp(),
                        'phone': phone.text.trim(),
                        // 'canComment': true,
                        // 'likes': [],
                        // 'value': randomValue,
                      });

                      // Update the document to add the ID field
                      await documentRef.update({'id': documentRef.id});
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'ADD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
