import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CloudStorage extends ChangeNotifier {
  static Reference storageRef = FirebaseStorage.instance.ref();

  // create a child reference
  // the avatar reference
  final avatarRef = storageRef.child("avatars");

  Future initAvatar(String uid) async {
    Uint8List avatar =
        (await rootBundle.load('assets/basic_avatar.jpg')).buffer.asUint8List();
    await storageRef.child('avatars/$uid').putData(avatar);
    notifyListeners();
  }

  Future uploadAvatar(String uid) async {
    FilePickerResult? result;

    result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png']);

    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;

      // Upload file
      await storageRef.child('avatars/$uid').putData(fileBytes);
      notifyListeners();
    }
  }

  Future<Uint8List?> getAvatar(String uid) async {
    Uint8List? imageBytes;

    await storageRef.child('avatars/$uid').getData(10485760).then((value) {
      imageBytes = value;
    });

    return imageBytes;
  }
}
