import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sober_steps/modules/communities/add_communities.dart';
import 'package:sober_steps/modules/communities/all_communities.dart';
import 'package:sober_steps/modules/communities/communities.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  String searchText = '';
  String admin = 'deian404e@gmail.com';

  void community() {
    final snackBar = const SnackBar(
      content: Text('Community section. Coming soon...'),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.purple,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void followers() {
    final snackBar = const SnackBar(
      content: Text('Followers section. Coming soon...'),
      duration: Duration(seconds: 3),
       backgroundColor: Colors.purple,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = FirebaseAuth.instance.currentUser?.email == admin;

    return Scaffold(
      body: DefaultTabController(
          length: 2,
          child: Column(children: [
            const SizedBox(
              height: 30,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              // height: 40,
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 1, color: Colors.white.withOpacity(0.7)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value
                              .toLowerCase(); // Update the searchText on text changes
                        });
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'search...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 63, 62, 62),
                        ),
                     
                        border: UnderlineInputBorder(),
                      
                      ),
                    ),
                  ),
                  Container(
                    // height: 40,
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: community,
                          child: Container(
                            // padding: const EdgeInsets.fromLTRB(6, 6, 6, 20),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.post_add, 
                              color: Colors.white,
                            size: 33,),
                          ),
                        ),
                       
                        GestureDetector(
                          onTap: followers,
                         child: Container(
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.account_box_outlined,
                               color: Colors.white,
                             size: 33,
                            ),
                          ),
                       ),
                         
                      ],
                    ),
                  ),
                
                  isAdmin
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AddCommunities(),
                            ));
                          },
                          child: const Icon(
                            Icons.add_task_outlined,
                            size: 36,
                            color: Colors.white,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
            TabBar(
                indicatorColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 4,
                dividerColor: Colors.white,
                unselectedLabelColor: Colors.grey[900],
                labelColor: Colors.grey[300],
                tabs: [
                  const Tab(
                    text: 'My Communities',
                  ),
                  const Tab(
                    text: 'Explore',
                  )
                ]),
            Expanded(
                child: TabBarView(children: [
              Communities(
                searchText: searchText, isAdmin: isAdmin,
              ),
              AllCommunities(
                searchText: searchText, isAdmin: isAdmin,
              ),
            ]))
          ])),
    );
  }
}
