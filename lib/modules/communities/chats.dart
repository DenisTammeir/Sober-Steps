import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sober_steps/modules/communities/admin.dart';
import 'package:http/http.dart' as http;

class Chats extends StatefulWidget {
  final chatid;
  final name;
  final isPart;
  final users;
  const Chats(
      {super.key,
      required this.chatid,
      required this.name,
      required this.isPart,
      required this.users});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final ScrollController _scrollController = ScrollController();
  final _auth = FirebaseAuth.instance;
  final TextEditingController _msgController = TextEditingController();
  bool isUploading = false;
  final picker = ImagePicker();

  final List<File> _imageFiles = [];

  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String server = "";

  Future<void> pickImages() async {
    final pickedImages = await picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      final List<File> newImages =
          pickedImages.map((image) => File(image.path)).toList();
      if (_imageFiles.length + newImages.length <= 30) {
        // Check the total number of images
        setState(() {
          _imageFiles.addAll(newImages);
        });
      } else {
        // Display a message or notification indicating the limit has been reached
      }
    }
  }

  Future<List<String>> uploadImages() async {
    final List<String> imageUrls = [];

    // Set isUploading to true to indicate that the upload has started
    isUploading = true;

    try {
      for (int i = 0; i < _imageFiles.length; i++) {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('chats/${DateTime.now().toString()}');
        final UploadTask uploadTask = storageReference.putFile(_imageFiles[i]);
        final TaskSnapshot snapshot = await uploadTask;
        final String url = await snapshot.ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      // Handle any errors that occur during image upload
      if (kDebugMode) {
        print('Error uploading images: $e');
      }
    } finally {
      // Set isUploading to false to indicate that the upload has finished
      isUploading = false;
    }

    // Perform any actions needed after image upload is complete
    // createChat();

    return imageUrls;
  }

  Future<void> sendPhoto() async {
    if (isUploading) {
      // setState(() {
      //   isUploading = true;
      // });
      return; // Prevent sending photos while upload is in progress
    }

    await pickImages();

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference messagesRef = firestore.collection('community-chats');

    // final userId = userAc?.uid;
    // String chatId = createChatId(widget.receiverId, userId!);

    try {
      final List<String> imageUrls = await uploadImages();

      for (String imageUrl in imageUrls) {
        DocumentReference documentRef = await messagesRef.add({
          'senderId': _auth.currentUser!.uid,
          'chatId': widget.chatid,
          'type': 'photo', // 'text' or 'image'
          'content': imageUrl, // Image URL
          // 'replyId': replyid,
          // 'replyContent': replyContent,
          // 'replyType': replyType,
          'timestamp': FieldValue.serverTimestamp(),
        });
        await documentRef.update({'id': documentRef.id});
      }
    } catch (e) {
      // Handle any errors that occur during image upload
      if (kDebugMode) {
        print('Error uploading images: $e');
      }
    }

    // Clear the list of selected images after successful upload
    setState(() {
      _imageFiles.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    // getFCMServerKey();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // After the frame is rendered, scroll to the bottom
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    String userId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 3,
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AdminSectionUI(
                users: widget.users,
                id: widget.chatid,
              ),
            ));
          },
          child: Text(
            widget.name,
            style: TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          !widget.isPart
              ? Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 6), // Adjust padding as needed
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('communities')
                            .doc(widget.chatid)
                            .update({
                          'users': FieldValue.arrayUnion([userId]),
                        }).then((_) {
                          print('User joined successfully');
                        }).catchError((error) {
                          print('Error  joining: $error');
                        });
                      },
                      child: const Text(
                        'Join',
                      )),
                )
              : Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: PopupMenuButton(
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: Text('Leave'),
                        value: 'Leave',
                      ),
                      // PopupMenuItem(
                      //   child: Text('Option 2'),
                      //   value: 'option2',
                      // ),
                      // PopupMenuItem(
                      //   child: Text('Option 3'),
                      //   value: 'option3',
                      // ),
                    ],
                    onSelected: (value) async {
                      // Handle menu item selection
                      print('Selected option: $value');
                      await FirebaseFirestore.instance
                          .collection('communities')
                          .doc(widget.chatid)
                          .update({
                        'users': FieldValue.arrayRemove([userId]),
                      }).then((_) {
                        print('User leave successful');
                      }).catchError((error) {
                        print('Error leaving: $error');
                      });
                    },
                    icon: Icon(
                      Icons.more_vert_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                )
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (MediaQuery.of(context).size.height) - 210,
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('community-chats')
                .where('chatId', isEqualTo: widget.chatid)
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No messages to show.'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }
              if (snapshot.error != null) {
                return const Center(
                  child: Text('Error loading messages.'),
                );
              }
              Map<String, List<Map<String, dynamic>>> messagesByDate = {};
              List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
              for (var document in documents) {
                // Check if the 'timestamp' field exists and is not null
                if (document['timestamp'] != null &&
                    document['timestamp'] is Timestamp) {
                  DateTime messageDate =
                      (document['timestamp'] as Timestamp).toDate();
                  String dateKey =
                      '${messageDate.year}-${messageDate.month.toString().padLeft(2, '0')}-${messageDate.day.toString().padLeft(2, '0')}';
                  messagesByDate[dateKey] ??= [];
                  messagesByDate[dateKey]!
                      .add(document.data() as Map<String, dynamic>);
                }
              }

              // Extract the date keys to use as subheadings
              List<String> dateKeys = messagesByDate.keys.toList();
              dateKeys.sort((a, b) {
                DateTime dateA = DateTime.parse(a);
                DateTime dateB = DateTime.parse(b);
                return dateB
                    .compareTo(dateA); // Sort dateKeys in descending order
              });
              return ListView.builder(
                  itemCount: dateKeys.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    String dateKey = dateKeys[index];
                    List<Map<String, dynamic>> messagesForDate =
                        messagesByDate[dateKey]!
                            .reversed
                            .toList(); // Reverse the list here

                    return Column(children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 214, 214, 214),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: Text(
                            dateKey,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).focusColor),
                          ),
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          controller: _scrollController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: messagesForDate.length,
                          itemBuilder: (context, index) {
                            if (index < messagesForDate.length) {
                              String messageText =
                                  messagesForDate[index]['content'];
                              String messageType =
                                  messagesForDate[index]['type'];

                              String isMe = messagesForDate[index]['senderId'];
                              String msgId = messagesForDate[index]['id'];
                              // String replyMsg =
                              //     messagesForDate[index]['replyContent'];

                              // String replyType =
                              //     messagesForDate[index]['replyType'];

                              // String msg = messagesForDate[index]['content'];

                              if (messagesForDate[index]['timestamp'] != null) {
                                Timestamp messageTime =
                                    messagesForDate[index]['timestamp'];
                                // Proceed with using messageTime
                                DateTime dateTime = messageTime.toDate();
                                // String u = user

                                String postTime =
                                    DateFormat('h:mm a').format(dateTime);
                                return Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(14, 10, 14, 10),
                                  child: IntrinsicHeight(
                                    child: FractionallySizedBox(
                                      alignment: isMe == userId
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      // widthFactor:
                                      //     0.6,
                                      child: Container(
                                        alignment: isMe == userId
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        width: isMe != userId
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .71
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .6,
                                        child: Container(
                                          // alignment: Alignment.center,
                                          width: isMe != userId
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .6
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .6,
                                          alignment: isMe == userId
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,

                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: isMe == userId
                                                ? Color.fromARGB(
                                                    255, 50, 197, 141)
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                            boxShadow: const [
                                              // BoxShadow(
                                              //     color: Color.fromARGB(
                                              //         255, 182, 182, 182), //New
                                              //     blurRadius: 2.0,
                                              //     offset: Offset(0, 1))
                                            ],
                                            // border: Border.all(
                                            //     width: 1,
                                            //     // style: BorderStyle.
                                            //     color: Theme.of(context).shadowColor),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(6)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              messageType == 'text'
                                                  ? Text(
                                                      messageText,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                          builder: (context) =>
                                                              SentImages(
                                                            photo: messageText,
                                                          ),
                                                        ));
                                                      },
                                                      child: Container(
                                                        height: 120,
                                                        child: Image.network(
                                                          messageText,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                              Container(
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        2, 10, 2, 2),
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                  postTime,
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.blue[800]),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                            return null;
                          }),
                    ]);
                  });
            },
          ),
        ),
      ),
      bottomSheet: widget.isPart
          ? Container(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              color: Theme.of(context).colorScheme.background,
              child: Form(
                child: IntrinsicHeight(
                  child: Container(
                    // height: 60,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Theme.of(context)
                          .colorScheme
                          .background
                          .withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromARGB(255, 63, 63, 63), //New
                            blurRadius: 3.0,
                            offset: Offset(1, 2))
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .62,
                          child: TextFormField(
                            controller: _msgController,
                            minLines: 1,
                            maxLines: 5,
                            style: TextStyle(
                              color: Colors.grey[200],
                            ),
                            decoration: InputDecoration(
                              hintText: 'Send message...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[200],
                                fontWeight: FontWeight.bold,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            sendPhoto();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.camera_alt_outlined),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_msgController.text.trim() != '') {
                              FirebaseFirestore firestore =
                                  FirebaseFirestore.instance;
                              CollectionReference messagesRef =
                                  firestore.collection('community-chats');

                              DocumentReference documentRef =
                                  await messagesRef.add({
                                'senderId': userId,
                                'chatId': widget.chatid,
                                'type': 'text', // 'text' or 'image'
                                'content':
                                    _msgController.text.trim(), // Image URL
                                // 'replyId': replyid,
                                // 'replyContent': replyContent,
                                // 'replyType': replyType,
                                'timestamp': FieldValue.serverTimestamp(),
                              });

                              await documentRef.update({'id': documentRef.id});
                              // String replyid, String replyContent, String replyType
                            }
                          },
                          child: const Icon(Icons.send_outlined),
                        ),
                        const SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
              color: Theme.of(context).colorScheme.background,
              child: Text(
                'Join the community to start participating in the conversations. Remember to be respectful to other users and the community guidelines.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ),
    );
  }
}

class SentImages extends StatefulWidget {
  final photo;
  const SentImages({super.key, required this.photo});

  @override
  State<SentImages> createState() => _SentImagesState();
}

class _SentImagesState extends State<SentImages> {
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    // Hide the notification bar when the page loads
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    // Make sure to enable system UI overlays when the page is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> requestStoragePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      // Permission granted, proceed with image selection
      _downloadImage();
    }
  }

  Future<void> _downloadImage() async {
    setState(() {
      _downloading = true;
    });
    final snackBar = SnackBar(
      content: const Text('Saving image...'),
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).primaryColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    try {
      // Make the HTTP GET request
      final http.Response response = await http.get(Uri.parse(widget.photo));

      // Get the DCIM directory
      final Directory dcimDir = Directory('/storage/emulated/0/Pictures');

      // Create a subdirectory with your app's name
      final Directory appDir = Directory('${dcimDir.path}/Agripert/Chats');
      if (!appDir.existsSync()) {
        await appDir.create(recursive: true);
      }

      // Get the current date and time
      final DateTime now = DateTime.now();

      // Format the date and time
      final String formattedDateTime =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}${now.second}';

      // Construct the file name
      final String fileName = 'IMG_$formattedDateTime.jpg';

      // Create a new file in the app directory with the constructed file name
      final File file = File('${appDir.path}/$fileName');

      // Write the image data to the file
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _downloading = false;
      });
    } catch (e) {
      print('errrororooroororr: $e');
      setState(() {
        _downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 4, 10, 10),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topRight,
            child: IconButton(
                onPressed: () {
                  requestStoragePermission();
                },
                icon: const Icon(
                  Icons.download,
                  color: Colors.grey,
                )),
          ),
          Expanded(
            child: Center(
              child: Image.network(
                widget.photo,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
