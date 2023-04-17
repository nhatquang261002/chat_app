// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatapp_firebase/screens/group_info_screen.dart';
import 'package:chatapp_firebase/services/database.dart';
import 'package:chatapp_firebase/widgets/message_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userName;
  const ChatScreen({
    Key? key,
    required this.groupName,
    required this.userName,
    required this.groupId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<QuerySnapshot>? chats;
  final _messageController = TextEditingController();
  String admin = "";

  @override
  void initState() {
    getChatAndAdmin();
    super.initState();
  }

  getChatAndAdmin() {
    DatabaseService().getChats(widget.groupId).then((value) {
      setState(() {
        chats = value;
      });
    });
    DatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        admin = value;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              print(widget.userName + '  ' + getName(admin));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (contex) => GroupInfoScreen(
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                    adminName: getName(admin),
                    userName: widget.userName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Stack(children: [
        chatMessages(),
        Container(
          alignment: Alignment.bottomCenter,
          width: size.width,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            width: size.width,
            color: Colors.grey[700],
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Send a message...",
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ]),
    );
  }

  chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        var dataLength = snapshot.data?.docs.length ?? 0;
        return dataLength != 0
            ? ListView.builder(
                itemCount: dataLength,
                itemBuilder: (context, index) {
                  return MessageTile(
                      message: snapshot.data!.docs[index]['message'],
                      sender: snapshot.data!.docs[index]['sender'],
                      sentByMe: widget.userName ==
                          snapshot.data!.docs[index]['sender']);
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (_messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'message': _messageController.text,
        'sender': widget.userName,
        'time': DateTime.now()
      };
      DatabaseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        _messageController.clear();
      });
    }
  }
}
