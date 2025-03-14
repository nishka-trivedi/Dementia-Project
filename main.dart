import 'package:dementia_app/symptoms.dart';
import 'package:dementia_app/takePhoto.dart';
import 'package:flutter/material.dart';

void main() => runApp(DementiaApp());

class DementiaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dementia Care App',
      theme: ThemeData(
        primaryColor: const Color(0xFFF8F3E7),
        scaffoldBackgroundColor: const Color(0xFFF8F3E7),
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 59, 77, 97),
          titleTextStyle: TextStyle(
            color: Color(0xFFF8F3E7),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 83, 102, 128),
            foregroundColor: const Color(0xFFF8F3E7),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dementia Care App')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to AIDE: AI for Dementia Evaluation",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 83, 102, 128),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Developing an AI and Machine Learning Model to Detect and Characterize Early Dementia",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 83, 102, 128),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Dementia affects over 55 million people worldwide, with nearly 10 million new cases diagnosed each year. However, early-stage dementia often goes undetected or misdiagnosed, delaying treatment and worsening outcomes.\n\n"
                "To help address this issue, I developed a mobile app that enables cost-effective and rapid early dementia screenings.\n\n"
                "This project introduces AIDE (AI for Dementia Evaluation), an AI-powered mobile application that utilizes deep learning tools to analyze MRI brain scans with 96.5% accuracy to detect early cognitive decline. AIDE enhances speed, accuracy, and accessibility in dementia screening, surpassing traditional diagnostic methods.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 83, 102, 128),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TakePhoto()),
                  );
                },
                child: const Text('Analyze MRI image'),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SymptomsPage()),
                  );
                },
                child: const Text(
                    'Analyze Symptoms \nPast Medical History, \nand Medications'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
