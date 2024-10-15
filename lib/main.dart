import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:storage_app/pages/image_upload_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Use GetMaterialApp for GetX functionalities
      title: 'Firebase Storage Demo',
      debugShowCheckedModeBanner: false,
      home: ImageUploadPage(),
    );
  }
}
