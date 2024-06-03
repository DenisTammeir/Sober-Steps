import 'package:flutter/material.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {

   TextEditingController postController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: TextFormField(
                              controller: postController,
                              maxLines: 6,
                              minLines: 4,
                              style: TextStyle(color: Colors.grey[100]),
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please provide a name.';
                              //   } else if (value.length > 16) {
                              //     return 'name must not exceed 16 characters';
                              //   } else if (!RegExp(r'[a-zA-Z]')
                              //       .hasMatch(value)) {
                              //     return 'Username must only contain letters!!';
                              //   }
                              //   return null;
                              // },
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 10, 20, 10),
                                border: InputBorder.none,
                                hintText: 'What is in your mind?',
                                hintStyle: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 11),
                              ),
                            ),
            )
          ],
        ),
      ),
    );
  }
}