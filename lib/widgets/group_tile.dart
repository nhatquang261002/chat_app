// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatapp_firebase/screens/chat_screen.dart';
import 'package:chatapp_firebase/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  final bool isJoined;
  bool disable;
  String recentMessage;
  String recentMessageSender;
  GroupTile({
    Key? key,
    required this.userName,
    required this.groupId,
    required this.groupName,
    required this.isJoined,
    this.recentMessage = '',
    this.recentMessageSender = '',
    this.disable = false,
  }) : super(key: key);

  @override
  _GroupTileState createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.disable
          ? () {
              _dialog();
            }
          : () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatScreen(
                          groupName: widget.groupName,
                          userName: widget.userName,
                          groupId: widget.groupId)));
            },
      child: Container(
        height: 85,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
          title: Text(
            widget.groupName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: widget.isJoined
              ? StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.groupId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text(
                        '...',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      );
                    } else {
                      var data = snapshot.data!.data();
                      if (data!['recentMessageSender'] == '') {
                        return const Text(
                          'Send your first message!',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        );
                      } else {
                        return Text(
                          "${data['recentMessageSender']}: ${data['recentMessage']}",
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        );
                      }
                    }
                  },
                )
              : Text(
                  'Join the conversation as ${widget.userName}',
                  style: const TextStyle(fontSize: 13),
                ),
        ),
      ),
    );
  }

  Future<void> _dialog() async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Do you want to join to this group?'),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    await DatabaseService(
                            uid: FirebaseAuth.instance.currentUser!.uid)
                        .toggleGroupJoin(
                            widget.groupId, widget.userName, widget.groupName);
                  },
                  icon: const Icon(
                    Icons.done,
                    color: Colors.green,
                  ),
                ),
              ],
            ));
  }
}
