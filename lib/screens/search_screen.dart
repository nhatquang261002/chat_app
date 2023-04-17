import 'package:chatapp_firebase/references/references.dart';
import 'package:chatapp_firebase/services/database.dart';
import 'package:chatapp_firebase/widgets/group_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  getCurrentUserIdAndName() async {
    await References.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red[300],
        title: const Text(
          "Search",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {});
                    },
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search groups....",
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                } else if (snapshot.hasData) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var groups = snapshot.data!.docs[index].data();
                        List members = groups['members'];

                        bool isJoined =
                            members.contains('${user!.uid}_$userName');

                        if (_searchController.text.isEmpty) {
                          return isJoined
                              ? GroupTile(
                                  isJoined: isJoined,
                                  userName: userName,
                                  groupId: groups['groupId'],
                                  groupName: groups['groupName'])
                              : GroupTile(
                                  disable: true,
                                  userName: userName,
                                  groupId: groups['groupId'],
                                  groupName: groups['groupName'],
                                  isJoined: isJoined);
                        }
                        if (groups['groupName']
                            .toString()
                            .toLowerCase()
                            .contains(
                              _searchController.text.toLowerCase(),
                            )) {
                          return isJoined
                              ? GroupTile(
                                  isJoined: isJoined,
                                  userName: userName,
                                  groupId: groups['groupId'],
                                  groupName: groups['groupName'])
                              : GroupTile(
                                  disable: true,
                                  userName: userName,
                                  groupId: groups['groupId'],
                                  groupName: groups['groupName'],
                                  isJoined: isJoined);
                        } else {
                          return Container();
                        }
                      });
                } else {
                  return const Center(
                    child: Text(
                      'There are currently no group of chat!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
