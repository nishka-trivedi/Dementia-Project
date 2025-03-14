// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:image_picker/image_picker.dart';

class TakePhoto extends StatefulWidget {
  @override
  _TakePhotoState createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  Map? results;
  bool loading = false;
  void uploadImage() async {
    if (_selectedFile == null) {
      return;
    }
    loading = true;
    final request = http.MultipartRequest(
        "POST", Uri.parse("http://10.0.2.2:5000/file_upload"));
    request.files
        .add(await http.MultipartFile.fromPath("image", _selectedFile!.path));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print("Raw Response: $responseBody"); // Debugging line

    if (responseBody.isEmpty) {
      setState(() {
        results = {"error": "Empty response from server"};
        loading = false;
      });
      return;
    }

    try {
      Map jsonResponse = jsonDecode(responseBody);
      print(jsonResponse); // Debugging line
      if (response.statusCode == 200) {
        setState(() {
          results = jsonResponse["result"];
          loading = false;
        });
      } else {
        setState(() {
          results = {"error": "Failed to fetch AI response"};
          loading = false;
        });
      }
    } catch (e) {
      print("Error decoding JSON: $e");
      setState(() {
        results = {"error": "Invalid response format"};
        loading = false;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
      _showSnackbar('Photo Taken');
      uploadImage();
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
      _showSnackbar('Photo Selected from Gallery');
      uploadImage();
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFF3B4D61),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
              child: const Text('Take a Photo'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
              child: const Text('Upload a Picture'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dementia Care App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _showBottomSheet,
                child: Text(_selectedFile == null
                    ? 'Proceed to Upload'
                    : "Upload Another Image"),
              ),
              SizedBox(height: 24),
              _selectedFile == null
                  ? SizedBox()
                  : SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.file(_selectedFile!, fit: BoxFit.cover),
                    ),
              SizedBox(height: 24),
              loading == true
                  ? CircularProgressIndicator()
                  : (results == null
                      ? SizedBox()
                      : Column(
                          children: [
                            Text(
                              "The machine learning model most likely predicts: ${results != null && results!.containsKey("label") ? results!["label"] : "Unknown"} with ${results != null && results!.containsKey("score") ? (results!["score"] * 100).toStringAsFixed(5) : "0.00000"}% accuracy.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 83, 102, 128),
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              "What does this mean?",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 83, 102, 128),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "According to the machine learning model, the given MRI has been classified with the given accuracy. This prediction is based on deep learning analysis, comparing the image with patterns learned from extensive MRI datasets. While AI predictions provide valuable insights, they should always be interpreted in conjunction with clinical evaluation by healthcare professionals.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 83, 102, 128),
                              ),
                            ),
                          ],
                        )),
            ],
          ),
        ),
      ),
    );
  }
}
