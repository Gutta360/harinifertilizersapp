import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JsonUploadWidget extends StatefulWidget {
  const JsonUploadWidget({super.key});

  @override
  State<JsonUploadWidget> createState() => _JsonUploadWidgetState();
}

class _JsonUploadWidgetState extends State<JsonUploadWidget> {
  String _uploadStatus = "";

  Future<void> _pickAndUploadFile() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.json';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsText(file);

        reader.onLoadEnd.listen((event) async {
          try {
            final jsonData = json.decode(reader.result as String) as Map<String, dynamic>;

            for (final entry in jsonData.entries) {
              final adminno = entry.key;
              final studentData = entry.value as Map<String, dynamic>;

              await FirebaseFirestore.instance
                  .collection("students")
                  .doc(adminno)
                  .set(studentData);
            }

            setState(() {
              _uploadStatus = "Upload successful ✅";
            });
          } catch (e) {
            setState(() {
              _uploadStatus = "Upload failed ❌: $e";
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text("Upload Students JSON"),
            onPressed: _pickAndUploadFile,
          ),
          const SizedBox(height: 16),
          Text(
            _uploadStatus,
            style: TextStyle(
              color: _uploadStatus.contains("failed") ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}