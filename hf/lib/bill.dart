import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class BillWidget extends StatefulWidget {
  const BillWidget({super.key});

  @override
  State<BillWidget> createState() => _BillWidgetState();
}

class _BillWidgetState extends State<BillWidget> {
  final _formKey = GlobalKey<FormState>();
  final _billNoController = TextEditingController();
  final _billAmountController = TextEditingController();
  DateTime _billDate = DateTime.now();
  String? _selectedCustomerName;
  String? _selectedAccountType;
  bool _isBillNoUnique = true;

  Map<String, Map<String, dynamic>> _customerMap = {};

  final List<String> _accountTypes = [
    "ANAMATH",
    "ANAMATH RECEIVED",
    "CREDIT",
    "CREDIT RECIEVED"
  ];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('customers').get();

    final Map<String, Map<String, dynamic>> customerMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final fullName = "${data['surname']} ${data['name']}";
      customerMap[fullName] = {
        'docId': doc.id,
        'phonenumber': data['phonenumber'],
      };
    }

    setState(() {
      _customerMap = customerMap;
    });
  }

  Future<bool> _isBillNoExists(String billNo) async {
    final query = await FirebaseFirestore.instance
        .collection('transactions')
        .where('billno', isEqualTo: billNo)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> _addBill() async {
    final billNo = _billNoController.text.trim();
    _isBillNoUnique = !(await _isBillNoExists(billNo));
    setState(() {});

    if (_formKey.currentState!.validate()) {
      final counterDoc = await FirebaseFirestore.instance
          .collection('counters')
          .doc('txn_counter')
          .get();
      int counter = counterDoc['value'];
      final newId = 'TXN0${(counter + 1).toString().padLeft(4, '0')}';

      final billAmount = double.parse(_billAmountController.text.trim());
      final billData = {
        'name': _selectedCustomerName,
        'billno': billNo,
        'billamount': double.parse(billAmount.toStringAsFixed(2)),
        'date': DateFormat('yyyy-MM-dd').format(_billDate),
        'type': _selectedAccountType
      };

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(newId)
          .set(billData);
      await FirebaseFirestore.instance
          .collection('counters')
          .doc('txn_counter')
          .update({'value': counter + 1});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bill added successfully'),
            backgroundColor: Colors.green),
      );

      _formKey.currentState!.reset();
      setState(() {
        _selectedCustomerName = null;
        _selectedAccountType = null;
        _billDate = DateTime.now();
      });
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> customerNames = _customerMap.keys.toList();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/creamatte.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Add Bill',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownSearch<String>(
                      items: customerNames,
                      selectedItem: _selectedCustomerName,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: _inputDecoration(
                            "Customer Name", Icons.person_outline),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            labelText: "Search Name",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        itemBuilder: (context, item, isSelected) {
                          final phone =
                              _customerMap[item]!['phonenumber'] ?? '';
                          return ListTile(
                            tileColor:
                                isSelected ? Colors.orange.shade100 : null,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item,
                                    style:
                                        const TextStyle(color: Colors.black)),
                                Text(phone,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ],
                            ),
                          );
                        },
                      ),
                      dropdownBuilder: (context, selectedItem) {
                        final phone = selectedItem != null
                            ? _customerMap[selectedItem]!['phonenumber']
                            : '';
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedItem ?? '',
                                style: const TextStyle(color: Colors.black)),
                            Text(phone ?? '',
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        );
                      },
                      onChanged: (value) =>
                          setState(() => _selectedCustomerName = value),
                      validator: (value) => value == null || value.isEmpty
                          ? "Name is required"
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _billNoController,
                      decoration: _inputDecoration("Bill No", Icons.numbers),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bill No is required';
                        } else if (!_isBillNoUnique) {
                          return 'Bill No already exists';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _billAmountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          _inputDecoration("Bill Amount", Icons.attach_money),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter bill amount';
                        final regex = RegExp(r'^\d+(\.\d{1,2})?$');
                        return regex.hasMatch(value)
                            ? null
                            : 'Enter valid amount (e.g., 123.45)';
                      },
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _billDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() => _billDate = pickedDate);
                        }
                      },
                      child: InputDecorator(
                        decoration:
                            _inputDecoration("Bill Date", Icons.calendar_today),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('yyyy-MM-dd').format(_billDate)),
                            const Icon(Icons.edit_calendar)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration(
                          "Account Type", Icons.account_balance_wallet),
                      value: _selectedAccountType,
                      items: _accountTypes
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedAccountType = value),
                      validator: (value) =>
                          value == null ? 'Select account type' : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _addBill,
                      icon: const Icon(Icons.add),
                      label: const Text("Add"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
