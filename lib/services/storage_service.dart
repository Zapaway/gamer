import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Methods for interacting with Firebase Storage.
class StorageService {
  static final storage = FirebaseStorage.instance;

  // getters
  /// Do not include root folder in [filePath].
  Reference getReferenceToFile(String filePath) {
    return storage.ref().child(filePath);
  }

  Future<ImageProvider> attemptToGetImageProviderFromFile(
    String filePath,
    ImageProvider backup
  ) async {
    try {
      final ref = storage.ref().child(filePath);
      return NetworkImage(await ref.getDownloadURL());
    }
    catch (e) {
      return backup;
    }
  }

  // setters
  /// Upload the user's profile picture from a Google content url.
  /// Returns the path to the file in Firebase Storage.
  Future<String> uploadUserPfpFromGooglePfpUrl(
    String userID, String url
  ) async {
    // allows it to be retrieved as a png
    final urlStem = url.split("=")[0];
    url = urlStem + "?photo.png";

    // temp store on user's device
    final response = await http.get(Uri.parse(url));
    final tempDirectory = await getTemporaryDirectory();
    final tempFile = File("${tempDirectory.path}/$userID.png");
    await tempFile.writeAsBytes(response.bodyBytes);

    // upload
    final firebaseStoragePath = "user_pfps/$userID.png";
    await storage.ref().child(firebaseStoragePath).putFile(tempFile);

    return firebaseStoragePath;
  }
}