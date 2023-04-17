import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  // saving user_data
  Future saveUserData(String fullName, String email) async {
    return await userCollection
        .doc(uid)
        .set({"fullName": fullName, "email": email, "groups": [], "uid": uid});
  }

  // getting user_data
  Future getUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  // get user groups
  Future getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // create a chat group
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });

    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // getting the chats
  Future getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentSnapshot documentSnapshot =
        await groupCollection.doc(groupId).get();
    return documentSnapshot['admin'];
  }

  // get group members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentSnapshot documentSnapshot = await userCollection.doc(uid).get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentSnapshot documentSnapshot = await userCollection.doc(uid).get();

    List<dynamic> groups = await documentSnapshot['groups'];

    if (groups.contains('${groupId}_$groupName')) {
      await userCollection.doc(uid).update({
        "groups": FieldValue.arrayRemove(['${groupId}_$groupName'])
      });
      await groupCollection.doc(groupId).update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userCollection.doc(uid).update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupCollection.doc(groupId).update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  Future deleteGroup(String groupId, String groupName) async {
    var snapshot = await userCollection
        .where('groups', arrayContains: '${groupId}_$groupName')
        .get();
    for (var element in snapshot.docs) {
      await userCollection.doc(element.id).update({
        "groups": FieldValue.arrayRemove(['${groupId}_$groupName'])
      });
    }
    await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
