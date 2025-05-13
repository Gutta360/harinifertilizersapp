import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';

class StudentDetailsWidget extends StatefulWidget {
  const StudentDetailsWidget({super.key});

  @override
  State<StudentDetailsWidget> createState() => _StudentDetailsWidgetState();
}

class _StudentDetailsWidgetState extends State<StudentDetailsWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _adminnoController = TextEditingController();
  final TextEditingController _studentnameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _studentaadharController = TextEditingController();
  final TextEditingController _fathernameController = TextEditingController();
  final TextEditingController _fatheraadharController = TextEditingController();
  final TextEditingController _fatherOccupationController = TextEditingController();
  final TextEditingController _fatherphnoController = TextEditingController();
  final TextEditingController _mothernameController = TextEditingController();
  final TextEditingController _motheraadharController = TextEditingController();
  final TextEditingController _motherOccupationController = TextEditingController();
  final TextEditingController _motherphnoController = TextEditingController();
  final TextEditingController _casteController = TextEditingController();
  final TextEditingController _subcasteController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  List<Map<String, String>> _students = [];
  String? _selectedStudentName;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    final snapshot = await FirebaseFirestore.instance.collection("students").get();
    final students = <Map<String, String>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey("studentname")) {
        students.add({"name": data["studentname"], "adminno": doc.id});
      }
    }

    setState(() {
      _students = students;
    });
  }

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
      labelStyle: const TextStyle(color: Colors.black),
      prefixIcon: icon != null ? Icon(icon, color: Colors.black) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: _inputDecoration(label),
        enabled: enabled,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildFieldGroup(String title, List<List<dynamic>> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 8.0, bottom: 8),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
        ),
        Column(
          children: List.generate((fields.length / 2).ceil(), (index) {
            int first = index * 2;
            int second = first + 1;
            return Row(
              children: [
                Expanded(
                    child: _buildTextField(fields[first][0], fields[first][1])),
                if (second < fields.length)
                  Expanded(
                      child: _buildTextField(
                          fields[second][0], fields[second][1])),
              ],
            );
          }),
        ),
      ],
    );
  }

  Future<void> _searchStudent(String studentName) async {
    final query = await FirebaseFirestore.instance
        .collection("students")
        .where("studentname", isEqualTo: studentName)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final data = doc.data();
      _adminnoController.text = doc.id;
      _studentnameController.text = data["studentname"] ?? '';
      _classController.text = data["class"] ?? '';
      _sectionController.text = data["section"] ?? '';
      _studentaadharController.text = data["studentaadhar"] ?? '';
      _fathernameController.text = data["fathername"] ?? '';
      _fatheraadharController.text = data["fatheraadhar"] ?? '';
      _fatherOccupationController.text = data["fatherOccupation"] ?? '';
      _fatherphnoController.text = data["fatherphno"] ?? '';
      _mothernameController.text = data["mothername"] ?? '';
      _motheraadharController.text = data["motheraadhar"] ?? '';
      _motherOccupationController.text = data["motherOccupation"] ?? '';
      _motherphnoController.text = data["motherphno"] ?? '';
      _casteController.text = data["caste"] ?? '';
      _subcasteController.text = data["subcaste"] ?? '';
      _feeController.text = double.parse(data["fees"].toString()).toStringAsFixed(2);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student not found")),
      );
    }
  }

  Future<void> _updateStudent() async {
    await FirebaseFirestore.instance
        .collection("students")
        .doc(_adminnoController.text)
        .update({
      "studentname": _studentnameController.text,
      "class": _classController.text,
      "section": _sectionController.text,
      "studentaadhar": _studentaadharController.text,
      "fathername": _fathernameController.text,
      "fatheraadhar": _fatheraadharController.text,
      "fatherOccupation": _fatherOccupationController.text,
      "fatherphno": _fatherphnoController.text,
      "mothername": _mothernameController.text,
      "motheraadhar": _motheraadharController.text,
      "motherOccupation": _motherOccupationController.text,
      "motherphno": _motherphnoController.text,
      "caste": _casteController.text,
      "subcaste": _subcasteController.text,
      "fee": _feeController.text,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Student updated")));
  }

  Future<void> _deleteStudent() async {
    await FirebaseFirestore.instance
        .collection("students")
        .doc(_adminnoController.text)
        .delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Student deleted")));
    _clearFields();
  }

  void _clearFields() {
    _studentnameController.clear();
    _classController.clear();
    _sectionController.clear();
    _studentaadharController.clear();
    _fathernameController.clear();
    _fatheraadharController.clear();
    _fatherOccupationController.clear();
    _fatherphnoController.clear();
    _mothernameController.clear();
    _motheraadharController.clear();
    _motherOccupationController.clear();
    _motherphnoController.clear();
    _casteController.clear();
    _subcasteController.clear();
    _feeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final studentFields = [
      [_adminnoController, "Admin No"],
      [_classController, "Class"],
      [_sectionController, "Section"],
      [_studentaadharController, "Student Aadhar"],
      [_casteController, "Caste"],
      [_subcasteController, "Subcaste"],
      [_feeController, "Fee"],
    ];

    final fatherFields = [
      [_fathernameController, "Father Name"],
      [_fatheraadharController, "Father Aadhar"],
      [_fatherOccupationController, "Father Occupation"],
      [_fatherphnoController, "Father Phone"],
    ];

    final motherFields = [
      [_mothernameController, "Mother Name"],
      [_motheraadharController, "Mother Aadhar"],
      [_motherOccupationController, "Mother Occupation"],
      [_motherphnoController, "Mother Phone"],
    ];

    final studentNames = _students.map((s) => s['name']!).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Details"),
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
          padding: const EdgeInsets.symmetric(horizontal: 96.0),
          child: ListView(
            padding: const EdgeInsets.all(12.0),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownSearch<String>(
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: const TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: "Search Name",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                              menuProps: const MenuProps(
                                backgroundColor:
                                    Color(0xFFFFF8E1), // Soft cream color
                                elevation: 4,
                              ),
                              itemBuilder: (context, item, isSelected) {
                                final matchedStudent = _students.firstWhere(
                                    (s) => s['name'] == item,
                                    orElse: () => {});
                                return ListTile(
                                  tileColor: isSelected
                                      ? Colors.orange.shade100
                                      : null,
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(matchedStudent['name'] ?? '',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      Text(matchedStudent['adminno'] ?? '',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                );
                              },
                            ),
                            items: _students.map((s) => s['name']!).toList(),
                            selectedItem: _selectedStudentName,
                            dropdownBuilder: (context, selectedItem) {
                              final matchedStudent = _students.firstWhere(
                                  (s) => s['name'] == selectedItem,
                                  orElse: () => {});
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(matchedStudent['name'] ?? '',
                                      style:
                                          const TextStyle(color: Colors.black)),
                                  Text(matchedStudent['adminno'] ?? '',
                                      style:
                                          const TextStyle(color: Colors.black)),
                                ],
                              );
                            },
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: "Name",
                                prefixIcon: Icon(Icons.account_circle),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedStudentName = value;
                                _studentnameController.text = value ?? '';
                              });
                              if (value != null) {
                                _searchStudent(value);
                              }
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? "Name is required"
                                : null,
                          ),
                        ),
                      ],
                    ),
                    _buildFieldGroup("Student Details", studentFields),
                    _buildFieldGroup("Father Details", fatherFields),
                    _buildFieldGroup("Mother Details", motherFields),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _updateStudent,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          child: const Text("Update"),
                        ),
                        ElevatedButton(
                          onPressed: _deleteStudent,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text("Delete"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
