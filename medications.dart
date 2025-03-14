// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, non_constant_identifier_names, unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:dementia_app/results.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class MedicationsPage extends StatefulWidget {
  final Map<dynamic, dynamic> symptoms_data;

  const MedicationsPage({super.key, required this.symptoms_data});

  @override
  _MedicationsPageState createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController start_date = TextEditingController();
  final TextEditingController dose = TextEditingController();
  final TextEditingController med_frequency = TextEditingController();
  final TextEditingController allergy_history = TextEditingController();

  final List<String> _medicationSuggestions = [
    "Donepezil",
    "Rivastigmine",
    "Memantine",
    "Galantamine"
  ];

  String? selectedMedication;
  String? startDate;
  String? dosage;
  String? frequency;
  String? prescriptionType;
  String? allergyHistory;

  get medication => null;

  void save_medication(medication) async {
    String apiurl = "http://10.0.2.2:5000";
    final response = await http.post(
        Uri.parse("${apiurl}/save_medication_and_symptoms"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(medication));
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
    } else {
      throw Exception("Could not fetch data");
    }
  }

  final _formKey = GlobalKey<FormState>();

  List<DropdownMenuItem<String>> _getDropdownItems() {
    return ['Prescribed', 'Over the Counter']
        .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            ))
        .toList();
  }

  void _submitMedication({bool addAnother = false}) {
    if (_formKey.currentState!.validate()) {
      Map<dynamic, dynamic> medication = {
        "Medication": selectedMedication,
        "Start Date": startDate,
        "Dosage": dosage,
        "Frequency": frequency,
        "Type": prescriptionType,
        "Allergy History": allergyHistory,
      };
      save_medication(medication);
      if (addAnother) {
        setState(() {
          selectedMedication = null;
          startDate = null;
          dosage = null;
          frequency = null;
          prescriptionType = null;
          allergyHistory = null;
          _medicationController.clear();
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultsPage(
                  symptomsData: widget.symptoms_data,
                  medicationsData: medication)),
        );
      }
    }
  }

  void skip() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ResultsPage(
              symptomsData: widget.symptoms_data, medicationsData: {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue value) {
                    if (value.text.isEmpty) return const Iterable.empty();
                    return _medicationSuggestions.where((medication) =>
                        medication
                            .toLowerCase()
                            .contains(value.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    setState(() {
                      selectedMedication = selection;
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    _medicationController.text = selectedMedication ?? '';
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: const InputDecoration(
                        labelText: 'Medication',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => startDate = value,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => dosage = value,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  value: prescriptionType,
                  items: _getDropdownItems(),
                  onChanged: (value) => setState(() {
                    prescriptionType = value;
                  }),
                  validator: (value) => value == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _submitMedication(),
                      child: const Text('Submit'),
                    ),
                    ElevatedButton(
                      onPressed: () => skip(),
                      child: const Text('Skip to Results'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
