// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResultsPage extends StatefulWidget {
  final Map<dynamic, dynamic> symptomsData;
  final Map<dynamic, dynamic> medicationsData;

  ResultsPage({required this.symptomsData, required this.medicationsData});

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String? aiResponse;
  String? mriImageUrl;
  bool loadingAI = false;
  bool loadingMRI = false;
  bool aiError = false;
  bool mriError = false;

  @override
  void initState() {
    super.initState();
    fetchAIResponse();
    fetchMRIImage();
  }

  Future<void> fetchAIResponse() async {
    String apiUrl = "http://10.0.2.2:5000/generate_ai_response";
    setState(() {
      loadingAI = true;
      aiError = false;
    });
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "symptoms": widget.symptomsData,
          "medications": widget.medicationsData
        }),
      );
      if (response.statusCode == 200) {
        var responseJson = jsonDecode(response.body);
        setState(() {
          aiResponse = responseJson['response']['Prediction analysis'] ??
              "No analysis available.";
          loadingAI = false;
        });
      } else {
        setState(() {
          aiResponse = "Failed to fetch AI response.";
          aiError = true;
          loadingAI = false;
        });
      }
    } catch (e) {
      setState(() {
        aiResponse = "Error processing AI response.";
        aiError = true;
        loadingAI = false;
      });
    }
  }

  Future<void> fetchMRIImage() async {
    String apiUrl = "http://10.0.2.2:5000/generate_mri";
    setState(() {
      loadingMRI = true;
      mriError = false;
    });
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(widget.symptomsData),
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          mriImageUrl = jsonResponse['image_url'];
          loadingMRI = false;
        });
      } else {
        setState(() {
          mriImageUrl = null;
          mriError = true;
          loadingMRI = false;
        });
      }
    } catch (e) {
      setState(() {
        mriImageUrl = null;
        mriError = true;
        loadingMRI = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Analysis Results')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "AI-Generated Analysis:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              loadingAI
                  ? CircularProgressIndicator()
                  : aiError
                      ? Text("Error: Unable to retrieve AI response.",
                          style: TextStyle(color: Colors.red))
                      : Text(aiResponse ?? "No analysis available.",
                          style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              const Text(
                "Predicted MRI Image Based on Symptoms:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              loadingMRI
                  ? CircularProgressIndicator()
                  : mriError
                      ? Text("Error: MRI scan prediction unavailable.",
                          style: TextStyle(color: Colors.red))
                      : (mriImageUrl != null
                          ? Image.network(mriImageUrl!)
                          : Text("MRI scan prediction unavailable.")),
            ],
          ),
        ),
      ),
    );
  }
}
