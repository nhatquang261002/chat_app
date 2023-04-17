// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatapp_firebase/services/cloud_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  final String userName;
  final String uid;
  Image avatar;
  ProfileScreen({
    Key? key,
    required this.email,
    required this.userName,
    required this.uid,
    required this.avatar,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 100,
        ),
        child: Column(
          children: [
            FutureBuilder(
                future: context.watch<CloudStorage>().getAvatar(widget.uid),
                builder: (context, snapshot) {
                  return CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: !snapshot.hasData
                          ? Image.asset('basic_avatar.jpg')
                          : Image.memory(
                              snapshot.data!,
                              fit: BoxFit.fill,
                            ),
                    ),
                  );
                }),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () async {
                      await context
                          .read<CloudStorage>()
                          .uploadAvatar(widget.uid);
                    },
                    child: const Text(
                      'Change your Avatar',
                      style: TextStyle(color: Colors.blue),
                    )),
                const SizedBox(
                  width: 15,
                ),
                TextButton(
                    onPressed: () async {
                      await context.read<CloudStorage>().initAvatar(widget.uid);
                    },
                    child: const Text(
                      'Delete Avatar',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Full Name",
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 17),
                ),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Email", style: TextStyle(fontSize: 17)),
                Text(widget.email, style: const TextStyle(fontSize: 17)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
