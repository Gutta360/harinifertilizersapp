import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    var newText = '';
    for (var i = 0; i < digitsOnly.length; i++) {
      newText += digitsOnly[i];
      if ((i + 1) % 4 == 0 && i + 1 != digitsOnly.length) {
        newText += ' ';
      }
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class StudentFormWidget extends StatefulWidget {
  const StudentFormWidget({super.key});

  @override
  State<StudentFormWidget> createState() => _StudentFormWidgetState();
}

class _StudentFormWidgetState extends State<StudentFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _adminnoController = TextEditingController();
  final TextEditingController _studentnameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _studentaadharController =
      TextEditingController();
  final TextEditingController _casteController = TextEditingController();
  final TextEditingController _subcasteController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _fathernameController = TextEditingController();
  final TextEditingController _fatheraadharController = TextEditingController();
  final TextEditingController _fatherOccupationController =
      TextEditingController();
  final TextEditingController _fatherphnoController = TextEditingController();
  final TextEditingController _mothernameController = TextEditingController();
  final TextEditingController _motheraadharController = TextEditingController();
  final TextEditingController _motherOccupationController =
      TextEditingController();
  final TextEditingController _motherphnoController = TextEditingController();

  // InputDecoration _inputDecoration(String label) {
  //   return InputDecoration(
  //     labelText: label,
  //     labelStyle: const TextStyle(color: Colors.black),
  //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //   );
  // }

  InputDecoration _inputDecoration(String label) {
    IconData? icon;
    switch (label.toLowerCase()) {
      case "admin no":
        icon = Icons.confirmation_number;
        break;
      case "class":
        icon = Icons.school;
        break;
      case "section":
        icon = Icons.view_agenda;
        break;
      case "student aadhar":
      case "father aadhar":
      case "mother aadhar":
        icon = Icons.credit_card;
        break;
      case "father name":
      case "mother name":
        icon = Icons.person;
        break;
      case "father occupation":
      case "mother occupation":
        icon = Icons.work;
        break;
      case "father phone":
      case "mother phone":
        icon = Icons.phone;
        break;
      case "caste":
        icon = Icons.group;
        break;
      case "subcaste":
        icon = Icons.group_add;
        break;
      case "fee":
        icon = Icons.attach_money;
        break;
    }

    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      labelStyle: const TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildFieldRow(List<Widget> children) {
    return Row(
      children: children
          .map((child) => Expanded(
              child: Padding(padding: const EdgeInsets.all(8.0), child: child)))
          .toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      List<TextInputFormatter> formatters, String? Function(String?) validator,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      inputFormatters: formatters,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: _inputDecoration(label),
      validator: validator,
    );
  }

  Widget _buildSection(String title, List<List<Widget>> rows) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 8),
          ...rows.map(_buildFieldRow),
        ],
      ),
    );
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState?.validate() ?? false) {
      double feeValue = double.tryParse(_feeController.text) ?? 0.0;
      await FirebaseFirestore.instance
          .collection("students")
          .doc(_adminnoController.text)
          .set({
        "adminno": _adminnoController.text,
        "studentname": _studentnameController.text,
        "class": _classController.text,
        "section": _sectionController.text,
        "studentaadhar": _studentaadharController.text,
        "caste": _casteController.text,
        "subcaste": _subcasteController.text,
        "fee": double.parse(feeValue.toStringAsFixed(2)),
        "fathername": _fathernameController.text,
        "fatheraadhar": _fatheraadharController.text,
        "fatherOccupation": _fatherOccupationController.text,
        "fatherphno": _fatherphnoController.text,
        "mothername": _mothernameController.text,
        "motheraadhar": _motheraadharController.text,
        "motherOccupation": _motherOccupationController.text,
        "motherphno": _motherphnoController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student saved successfully!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Registration Form"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/creamatte.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/creamatte.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 96.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection("Student Details", [
                    [
                      _buildTextField(
                          _adminnoController,
                          "Admin No",
                          [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                      _buildTextField(
                          _classController,
                          "Class",
                          [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                    ],
                    [
                      _buildTextField(
                          _sectionController,
                          "Section",
                          [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                      _buildTextField(
                          _studentaadharController,
                          "Student Aadhar",
                          [
                            LengthLimitingTextInputFormatter(14),
                            AadhaarInputFormatter()
                          ],
                          (value) => value!.replaceAll(' ', '').length == 12
                              ? null
                              : 'Enter 12 digit Aadhaar',
                          keyboardType: TextInputType.number),
                    ],
                    [
                      _buildTextField(
                          _casteController,
                          "Caste",
                          [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                      _buildTextField(
                          _subcasteController,
                          "Subcaste",
                          [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                    ],
                    [
                      _buildTextField(
                          _feeController,
                          "Fee",
                          [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true)),
                      _buildTextField(
                          _studentnameController,
                          "Student Name",
                          [
                            LengthLimitingTextInputFormatter(30),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                    ],
                  ]),
                  _buildSection("Father Details", [
                    [
                      _buildTextField(
                          _fathernameController,
                          "Father Name",
                          [
                            LengthLimitingTextInputFormatter(30),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                      _buildTextField(
                          _fatheraadharController,
                          "Father Aadhar",
                          [
                            LengthLimitingTextInputFormatter(14),
                            AadhaarInputFormatter()
                          ],
                          (value) => value!.replaceAll(' ', '').length == 12
                              ? null
                              : 'Enter 12 digit Aadhaar',
                          keyboardType: TextInputType.number),
                    ],
                    [
                      _buildTextField(
                          _fatherOccupationController,
                          "Father Occupation",
                          [
                            LengthLimitingTextInputFormatter(30),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                      _buildTextField(
                          _fatherphnoController,
                          "Father Phone",
                          [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          (value) => value!.length == 10
                              ? null
                              : 'Enter 10 digit phone',
                          keyboardType: TextInputType.phone),
                    ],
                  ]),
                  _buildSection("Mother Details", [
                    [
                      _buildTextField(
                          _mothernameController,
                          "Mother Name",
                          [
                            LengthLimitingTextInputFormatter(30),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                      _buildTextField(
                          _motheraadharController,
                          "Mother Aadhar",
                          [
                            LengthLimitingTextInputFormatter(14),
                            AadhaarInputFormatter()
                          ],
                          (value) => value!.replaceAll(' ', '').length == 12
                              ? null
                              : 'Enter 12 digit Aadhaar',
                          keyboardType: TextInputType.number),
                    ],
                    [
                      _buildTextField(
                          _motherOccupationController,
                          "Mother Occupation",
                          [
                            LengthLimitingTextInputFormatter(30),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z ]'))
                          ],
                          (value) => value!.isEmpty ? 'Required' : null),
                      _buildTextField(
                          _motherphnoController,
                          "Mother Phone",
                          [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          (value) => value!.length == 10
                              ? null
                              : 'Enter 10 digit phone',
                          keyboardType: TextInputType.phone),
                    ],
                  ]),
                  const SizedBox(height: 20),
                  Center(
                      child: ElevatedButton(
                          onPressed: _saveStudent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor:
                                Colors.white, // sets text/icon color to white
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          child: const Text("Save"))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
