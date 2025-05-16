import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class JsonUploadWidget extends StatefulWidget {
  const JsonUploadWidget({Key? key}) : super(key: key);

  @override
  State<JsonUploadWidget> createState() => _JsonUploadWidgetState();
}

class _JsonUploadWidgetState extends State<JsonUploadWidget> {
  String status = "";
  bool firebaseReady = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyAl0ra3F7-p_77Czgw8lS9fISW2WBeO_iI",
            authDomain: "hffa-3ea40.firebaseapp.com",
            projectId: "hffa-3ea40",
            storageBucket: "hffa-3ea40.firebasestorage.app",
            messagingSenderId: "595514369377",
            appId: "1:595514369377:web:e14b9878ccae0ce5499120",
            measurementId: "G-6WZN6JDQ0X",
          ),
        );
      }
      setState(() {
        firebaseReady = true;
        status = "✅ Firebase initialized successfully.";
      });
    } catch (e) {
      setState(() {
        status = "❌ Firebase initialization failed: $e";
      });
      debugPrint("Firebase init error: $e");
    }
  }

  Future<void> _uploadJsonToFirestore() async {
    if (!firebaseReady) {
      setState(() {
        status = "❗ Firebase is not ready yet.";
      });
      return;
    }

    setState(() {
      status = "📂 Opening file picker...";
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.single.bytes == null) {
      setState(() {
        status = "No file selected or file data unavailable.";
      });
      return;
    }

    Uint8List fileBytes = result.files.single.bytes!;
    String fileName = result.files.single.name;
    String collectionName = fileName.split('.').first;

    setState(() {
      status = "🔄 Reading and validating JSON file...";
    });

    try {
      String content = utf8.decode(fileBytes);
      final decoded = json.decode(content);

      if (decoded is! Map<String, dynamic>) {
        setState(() {
          status = "❌ Invalid JSON format: expected a map of document IDs to data objects.";
        });
        return;
      }

      Map<String, dynamic> jsonData = decoded;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      WriteBatch batch = firestore.batch();
      CollectionReference collectionRef = firestore.collection(collectionName);

      for (String docId in jsonData.keys) {
        DocumentReference docRef = collectionRef.doc(docId);
        batch.set(docRef, jsonData[docId]);
      }

      await batch.commit();
      setState(() {
        status = "✅ Successfully uploaded ${jsonData.length} records to '$collectionName'.";
      });
    } catch (e) {
      setState(() {
        status = "❌ Error during upload: $e";
      });
      debugPrint("Upload error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload JSON to Firestore")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _uploadJsonToFirestore,
              child: const Text("📂 Browse and Upload JSON File"),
            ),
            const SizedBox(height: 20),
            Text(
              status,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
