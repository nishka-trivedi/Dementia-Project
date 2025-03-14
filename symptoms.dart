// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:dementia_app/medications.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class SymptomsPage extends StatefulWidget {
  @override
  _SymptomsPageState createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _additionalNotesController =
      TextEditingController();
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _historyDurationController =
      TextEditingController();
  final TextEditingController _howLongAgoController = TextEditingController();
  final TextEditingController _historyFrequencyController =
      TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _medStartDateController = TextEditingController();
  final TextEditingController _medDosageController = TextEditingController();
  final TextEditingController _medFrequencyController = TextEditingController();
  final TextEditingController _medTypeController = TextEditingController();
  final TextEditingController _medAllergyHistoryController =
      TextEditingController();

  List<Map<String, String>> savedSymptoms = [];
  List<String> selectedSymptoms = [];
  List<String> selectedHistories = [];
  List<String> selectedMedications = [];
  String? duration;
  String? severity;
  String? historyDuration;
  String? historySeverity;
  String? howLongAgo;
  String? historyFrequency;
  String? medStartDate;
  String? medDosage;
  String? medFrequency;
  String? medType;
  String? medAllergyHistory;
  bool showSymptomFields = false;
  bool showHistorySection = false;
  bool showHistoryFields = false;
  bool showMedicationSection = false;
  bool showMedicationFields = false;
  bool addAnother = false;

  final List<String> _symptomSuggestions = [
    "Rapid Memory Loss",
    "Gradual Memory Loss",
    "Difficulty Concentrating",
    "Mood Swings",
    "Confusion",
    "Slower Thinking Speed",
    "Decreased Problem-Solving Ability",
    "Changes In Behavior",
    "Changes In Personality",
    "Changes In Language",
    "Cognitive Decline",
    "Decreased Balance",
    "Visual Hallucinations",
    "Lack of Dopamine",
    "Motivational Changes",
    "Learning Decline",
    "Lack of Concentration",
    "Impaired Judgement",
    "Sudden Apathy",
    "Speech Issues",
    "Loss of Coordination",
    "Decline of Ability to Perform Basic Tasks"
  ];

  final List<String> _historySuggestions = [
    "Hypertension",
    "Diabetes",
    "Stroke",
    "Heart Disease",
    "Traumatic Brain Injury",
    "Depression",
    "Anxiety",
    "Chronic Kidney Disease",
    "Hypothyroidism",
    "Hyperthyroidism",
    "Multiple Sclerosis",
    "Epilepsy",
    "Brain Tumor",
    "Sleep Apnea",
    "Hearing Loss",
    "Vitamin B12 Deficiency"
  ];

  final _formKey = GlobalKey<FormState>();
  void fill_in_data() {
    _symptomController.text = savedSymptoms[0].toString();
  }

  void add_symptom_icon() {
    FloatingActionButton:
    FloatingActionButton(
      onPressed: fill_in_data,
    );
  }

  void save_symptom_and_history(Map<String, dynamic> data) async {
    String apiurl = "http://10.0.2.2:5000";
    final response = await http.post(
      Uri.parse("${apiurl}/save_medication_and_symptoms"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
    } else {
      throw Exception("Could not save data");
    }
  }

  List<DropdownMenuItem<String>> _getSeverityDropdownItems() {
    return ['Mild', 'Moderate', 'Severe']
        .map((level) => DropdownMenuItem(
              value: level,
              child: Text(level),
            ))
        .toList();
  }

  void _addAnotherSymptom() {
    setState(() {
      if (_symptomController.text.isNotEmpty) {
        savedSymptoms.add({
          "symptom": _symptomController.text,
          "duration": _durationController.text,
          "severity": severity ?? "",
          "additionalNotes": _additionalNotesController.text,
        });
        add_symptom_icon();
        _symptomController.clear();
        _durationController.clear();
        _additionalNotesController.clear();
        severity = null;
      }
      showSymptomFields = false;
    });
  }

  void _submitSymptoms({bool addAnother = false}) {
    setState(() {
      if (!addAnother) {
        showHistorySection = true;
      }
      showSymptomFields = false;
    });
  }

  void _submitHistories() {
    Map<String, dynamic> data = {
      "Symptoms": selectedSymptoms,
      "Duration": duration,
      "Severity": severity,
      "Additional Notes": _additionalNotesController.text,
      "Past Medical History": selectedHistories,
      "History Frequency": historyFrequency,
      "History Duration": historyDuration,
      "History Severity": historySeverity,
      "History How Long Ago": howLongAgo,
    };
    print(data);
    save_symptom_and_history(data);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MedicationsPage(symptoms_data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symptoms')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Symptoms Input with Autocomplete
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue value) {
                    if (value.text.isEmpty) return const Iterable.empty();
                    return _symptomSuggestions.where((symptom) => symptom
                        .toLowerCase()
                        .contains(value.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    setState(() {
                      selectedSymptoms.add(selection);
                      showSymptomFields = true;
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: const InputDecoration(
                        labelText: 'Enter Symptom',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Display additional fields when a symptom is added
                if (showSymptomFields) ...[
                  TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (e.g., 3 weeks)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => duration = value,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      border: OutlineInputBorder(),
                    ),
                    value: severity,
                    items: _getSeverityDropdownItems(),
                    onChanged: (value) => setState(() {
                      severity = value;
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _additionalNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitSymptoms,
                    child: const Text('Submit Symptoms'),
                  ),
                ],

                // History Input Section (Appears after symptoms are submitted)
                if (showHistorySection) ...[
                  const SizedBox(height: 24),
                  const Text("Past Medical History",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue value) {
                      if (value.text.isEmpty) return const Iterable.empty();
                      return _historySuggestions.where((history) => history
                          .toLowerCase()
                          .contains(value.text.toLowerCase()));
                    },
                    onSelected: (String selection) {
                      setState(() {
                        selectedHistories.add(selection);
                        showHistoryFields = true;
                      });
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: const InputDecoration(
                          labelText: 'Enter Past Medical History',
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (showHistoryFields) ...[
                    TextFormField(
                      controller: _historyDurationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => historyDuration = value,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'History Severity',
                        border: OutlineInputBorder(),
                      ),
                      value: historySeverity,
                      items: _getSeverityDropdownItems(),
                      onChanged: (value) => setState(() {
                        historySeverity = value;
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _howLongAgoController,
                      decoration: const InputDecoration(
                        labelText: 'How Long Ago?',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => howLongAgo = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _historyFrequencyController,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => historyFrequency = value,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _submitHistories(),
                      child: const Text('Submit History'),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
