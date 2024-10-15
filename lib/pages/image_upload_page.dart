import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, String>> _imageData = []; // Stores both URL and file name
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    File file = File(image.path);
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final ref = _storage.ref('uploads/${image.name}');
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        setState(() {
          _uploadProgress =
              taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        });
      });

      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();

      setState(() {
        _imageData.add({'url': downloadUrl, 'name': image.name});
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      Get.snackbar('Success', 'Image uploaded successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      print('Error uploading image: $e');
    }
  }

  Future<void> deleteImage(String imageName) async {
    try {
      await _storage.ref('uploads/$imageName').delete();
      setState(() {
        _imageData.removeWhere((data) => data['name'] == imageName);
      });
      print('Image deleted successfully');
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  void _showDeleteConfirmationDialog(String imageName) {
    Get.defaultDialog(
      title: 'Delete Image',
      middleText: 'Do you want to delete this image?',
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      onConfirm: () {
        deleteImage(imageName);
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  void _viewFullScreenImage(String imageUrl) {
    Get.to(() => FullScreenImagePage(imageUrl: imageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.brown,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Firebase Storage Demo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _imageData.length + (_isUploading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isUploading && index == _imageData.length) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Shimmer(
                          duration: Duration(seconds: 2), // shimmer duration
                          interval:
                              Duration(seconds: 1), // delay between animations
                          color: Colors.red, // shimmer color
                          colorOpacity: 0.3, // shimmer color opacity
                          enabled: true,
                          child: Container(
                            width: 100,
                            height: 150,
                            color: Colors.brown[300],
                          ),
                        ),
                      );
                    } else {
                      final imageData = _imageData[index];
                      return GestureDetector(
                        onLongPress: () =>
                            _showDeleteConfirmationDialog(imageData['name']!),
                        onTap: () => _viewFullScreenImage(imageData['url']!),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 100,
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageData['url']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              FloatingActionButton(
                onPressed: uploadImage,
                child: Icon(Icons.camera_alt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () => Get.back(),
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
