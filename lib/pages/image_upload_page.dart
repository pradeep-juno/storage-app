import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  String? _imageUrl;

  Future<void> uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File file = File(image.path);
    try {
      await _storage.ref('uploads/${image.name}').putFile(file);
      String downloadUrl =
          await _storage.ref('uploads/${image.name}').getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> deleteImage(String imageName) async {
    try {
      await _storage.ref('uploads/$imageName').delete();
      setState(() {
        _imageUrl = null;
      });
      print('Image deleted successfully');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Storage Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_imageUrl != null)
              Column(
                children: [
                  Image.network(_imageUrl!),
                  ElevatedButton(
                    onPressed: () => deleteImage(_imageUrl!.split('/').last),
                    child: Text('Delete Image'),
                  ),
                ],
              ),
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
