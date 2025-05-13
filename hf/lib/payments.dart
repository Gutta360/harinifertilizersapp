import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:dropdown_search/dropdown_search.dart';

class PaymentFormWidget extends StatefulWidget {
  const PaymentFormWidget({super.key});

  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _studentnameController = TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _fathernameController = TextEditingController();
  final TextEditingController _fatherphnoController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();

  double percent = 0.0;
  List<Map<String, dynamic>> _students = [];
  String? _selectedStudentName;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _paidController.addListener(_updatePercent);
    _feeController.addListener(_updatePercent);
  }

  void _updatePercent() {
    final double paid = double.tryParse(_paidController.text) ?? 0.0;
    final double fee = double.tryParse(_feeController.text) ?? 1.0;
    setState(() {
      percent = fee > 0 ? (paid / fee).clamp(0.0, 1.0) : 0.0;
    });
  }

  Future<void> _fetchStudents() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("students").get();
    final students = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "name": data["studentname"] ?? '',
        "adminno": doc.id,
        "class": data["class"] ?? '',
        "fathername": data["fathername"] ?? '',
        "fatherphno": data["fatherphno"]?.toString() ?? '',
        "fee": (data["fee"] != null) ? data["fee"].toDouble() : 0.0,
      };
    }).toList();

    setState(() {
      _students = students;
    });
  }

  void _searchStudent(String name) {
    final matched =
        _students.firstWhere((s) => s['name'] == name, orElse: () => {});
    setState(() {
      _feeController.text = matched['fee']?.toString() ?? '';
      _classController.text = matched['class'] ?? '';
      _fathernameController.text = matched['fathername'] ?? '';
      _fatherphnoController.text = matched['fatherphno'] ?? '';
    });
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState?.validate() ?? false) {
      await FirebaseFirestore.instance.collection("payments").add({
        "studentname": _studentnameController.text,
        "paymentAmount": _paymentAmountController.text,
        "class": _classController.text,
        "fathername": _fathernameController.text,
        "fatherphno": _fatherphnoController.text,
        "fee": _feeController.text,
        "paid": _paidController.text,
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Payment saved")));
    }
  }

  InputDecoration _inputDecoration(String label) {
    IconData? icon;
    switch (label.toLowerCase()) {
      case "student name":
      case "father name":
        icon = Icons.person;
        break;
      case "class":
        icon = Icons.school;
        break;
      case "father phone":
        icon = Icons.phone;
        break;
      case "payment amount":
      case "fee":
      case "paid":
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.black),
        decoration: _inputDecoration(label),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Color _getProgressColor(double percent) {
    if (percent >= 0.8) return Colors.green;
    if (percent >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<TextEditingController, String>> paymentFields = [
      MapEntry(_paymentAmountController, "Payment Amount"),
      MapEntry(_classController, "Class"),
      MapEntry(_fathernameController, "Father Name"),
      MapEntry(_fatherphnoController, "Father Phone"),
      MapEntry(_feeController, "fee"),
      MapEntry(_paidController, "Paid"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Form"),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 12.0),
                      child: Text(
                        "Payment Details",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
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
                                backgroundColor: Color(0xFFFFF8E1),
                                elevation: 4,
                              ),
                              itemBuilder: (context, item, isSelected) {
                                final student = _students.firstWhere(
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
                                      Text(student['name'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.black)),
                                      Text(student['adminno'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.black)),
                                    ],
                                  ),
                                );
                              },
                            ),
                            items: _students
                                .map((s) => s['name'] as String)
                                .toList(),
                            selectedItem: _selectedStudentName,
                            dropdownBuilder: (context, selectedItem) {
                              final student = _students.firstWhere(
                                  (s) => s['name'] == selectedItem,
                                  orElse: () => {});
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(student['name'] ?? '',
                                      style:
                                          const TextStyle(color: Colors.black)),
                                  Text(student['adminno'] ?? '',
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
                              if (value != null) _searchStudent(value);
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? "Name is required"
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width * 0.2,
                          animation: true,
                          animationDuration: 1000,
                          lineHeight: 20.0,
                          leading: Text(
                              "Paid: ${_paidController.text.isNotEmpty ? _paidController.text : "0.0"}",
                              style: const TextStyle(fontSize: 14)),
                          trailing: Text(
                              "Total: ${_feeController.text.isNotEmpty ? _feeController.text : "0.0"}",
                              style: const TextStyle(fontSize: 14)),
                          percent: percent,
                          center: Text("${(percent * 100).toStringAsFixed(1)}%",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white)),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: _getProgressColor(percent),
                          backgroundColor: Colors.grey[300],
                        ),
                      ],
                    ),
                    Column(
                      children: List.generate((paymentFields.length / 2).ceil(),
                          (index) {
                        int first = index * 2;
                        int second = first + 1;
                        return Row(
                          children: [
                            Expanded(
                                child: _buildTextField(paymentFields[first].key,
                                    paymentFields[first].value)),
                            if (second < paymentFields.length)
                              Expanded(
                                  child: _buildTextField(
                                      paymentFields[second].key,
                                      paymentFields[second].value)),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: _savePayment, child: const Text("SAVE")),
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
