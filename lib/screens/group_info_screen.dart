// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatapp_firebase/references/references.dart';
import 'package:chatapp_firebase/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  final String adminName;
  const GroupInfoScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName,
    required this.adminName,
  }) : super(key: key);

  @override
  _GroupInfoScreenState createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  @override
  void initState() {
    super.initState();
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  memberList() {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!['members'] != null) {
              if (snapshot.data!['members'].length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data!['members'].length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            getName(snapshot.data!['members'][index])
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(getName(snapshot.data!['members'][index])),
                        subtitle: Text(getId(snapshot.data!['members'][index])),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text("NO MEMBERS"),
                );
              }
            } else {
              return const Center(
                child: Text("NO MEMBERS"),
              );
            }
          } else {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.userName == widget.adminName;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Group Info'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Exit Group'),
                    content:
                        const Text('Are you sure you want to exit this group?'),
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          DatabaseService(
                                  uid: FirebaseAuth.instance.currentUser!.uid)
                              .toggleGroupJoin(widget.groupId,
                                  getName(widget.userName), widget.groupName);
                        },
                        icon: const Icon(
                          Icons.done,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          widget.groupName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Text(
                            'Group: ${widget.groupName}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text("Admin: ${getName(widget.adminName)}"),
                        ],
                      ),
                    ],
                  ),
                  isAdmin
                      ? IconButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            await DatabaseService()
                                .deleteGroup(widget.groupId, widget.groupName);
                          },
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ))
                      : Container()
                ],
              ),
            ),
            memberList(),
          ],
        ),
      ),
    );
  }
}
