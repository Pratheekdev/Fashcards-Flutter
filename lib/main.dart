import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(apiKey: "AIzaSyC0wuP3xAXYJfOz4FutD0FedcqhLc-JXjw",
  authDomain: "flashcards-664c4.firebaseapp.com",
  projectId: "flashcards-664c4",
  storageBucket: "flashcards-664c4.firebasestorage.app",
  messagingSenderId: "944636255149",
  appId: "1:944636255149:web:236b970748e0340f3ddf24"),
  );
  runApp(FlashcardsApp());
}

class FlashcardsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flashcards App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}