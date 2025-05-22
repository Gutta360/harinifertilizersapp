import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BillDetailsWidget extends StatefulWidget {
  const BillDetailsWidget({super.key});

  @override
  State<BillDetailsWidget> createState() => _BillDetailsWidgetState();
}

class _BillDetailsWidgetState extends State<BillDetailsWidget> {
  final _formKey = GlobalKey<FormState>();
  final _billAmountController = TextEditingController();
  DateTime _billDate = DateTime.now();
  String? _selectedCustomerName;
  String? _selectedBillNo;
  String? _selectedAccountType;

  Map<String, Map<String, dynamic>> _customerMap = {};
  List<String> _customerDisplayList = [];
  List<String> _billNumbers = [];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final snapshot = await FirebaseFirestore.instance.collection('customers').get();
    final Map<String, Map<String, dynamic>> customerMap = {};
    final List<String> displayList = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final fullName = "${data['surname']} ${data['name']}";
      final displayName = fullName;
      customerMap[displayName] = {
        'docId': doc.id,
        'phonenumber': data['phonenumber'],
        'actualName': fullName
      };
      displayList.add(displayName);
    }
    setState(() {
      _customerMap = customerMap;
      _customerDisplayList = displayList;
    });
  }

  Future<void> _fetchBillNumbers() async {
    if (_selectedCustomerName == null) return;
    final actualName = _customerMap[_selectedCustomerName!]?['actualName'];
    if (actualName == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('name', isEqualTo: actualName)
        .get();
    final List<String> billNos = snapshot.docs.map((doc) => doc['billno'] as String).toList();
    setState(() {
      _billNumbers = billNos;
    });
  }

  Future<void> _loadBillDetails() async {
    final actualName = _customerMap[_selectedCustomerName!]?['actualName'];
    if (actualName == null || _selectedBillNo == null) return;
    final query = await FirebaseFirestore.instance
        .collection('transactions')
        .where('name', isEqualTo: actualName)
        .where('billno', isEqualTo: _selectedBillNo)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      setState(() {
        _billAmountController.text = data['billamount'].toString();
        _billDate = DateFormat('yyyy-MM-dd').parse(data['date']);
        _selectedAccountType = data['type'];
      });
    }
  }

  Future<void> _updateBill() async {
    final actualName = _customerMap[_selectedCustomerName!]?['actualName'];
    if (actualName == null || _selectedBillNo == null) return;
    final query = await FirebaseFirestore.instance
        .collection('transactions')
        .where('name', isEqualTo: actualName)
        .where('billno', isEqualTo: _selectedBillNo)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      await FirebaseFirestore.instance.collection('transactions').doc(docId).update({
        'billamount': double.parse(_billAmountController.text.trim()),
        'date': DateFormat('yyyy-MM-dd').format(_billDate),
        'type': _selectedAccountType,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill updated successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deleteBill() async {
    final actualName = _customerMap[_selectedCustomerName!]?['actualName'];
    if (actualName == null || _selectedBillNo == null) return;
    final query = await FirebaseFirestore.instance
        .collection('transactions')
        .where('name', isEqualTo: actualName)
        .where('billno', isEqualTo: _selectedBillNo)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;
      await FirebaseFirestore.instance.collection('transactions').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownSearch<String>(
                  items: _customerDisplayList,
                  selectedItem: _selectedCustomerName,
                  dropdownBuilder: (context, selectedItem) => selectedItem == null
                      ? const Text('')
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedItem),
                            Text(
                              _customerMap[selectedItem]?['phonenumber'] ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                  popupProps: PopupProps.menu(
                    itemBuilder: (context, item, isSelected) => ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item),
                          Text(
                            _customerMap[item]?['phonenumber'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    showSearchBox: true,
                    searchFieldProps: const TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'Search Name',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: _inputDecoration("Customer Name", Icons.person),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedCustomerName = value;
                      _selectedBillNo = null;
                      _billAmountController.clear();
                      _selectedAccountType = null;
                    });
                    _fetchBillNumbers();
                  },
                  validator: (value) => value == null ? 'Select a customer' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedBillNo,
                  decoration: _inputDecoration("Bill No", Icons.receipt_long),
                  items: _billNumbers.map((bill) => DropdownMenuItem(value: bill, child: Text(bill))).toList(),
                  onChanged: (value) {
                    setState(() => _selectedBillNo = value);
                    _loadBillDetails();
                  },
                  validator: (value) => value == null ? 'Select a bill number' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _billAmountController,
                  decoration: _inputDecoration("Bill Amount", Icons.currency_rupee),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter bill amount';
                    final regex = RegExp(r'^\d+(\.\d{1,2})?$');
                    return regex.hasMatch(value) ? null : 'Enter valid amount (e.g., 123.45)';
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
                    decoration: _inputDecoration("Bill Date", Icons.calendar_today),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('yyyy-MM-dd').format(_billDate)),
                        const Icon(Icons.edit_calendar),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Account Type", Icons.account_balance_wallet),
                  value: _selectedAccountType,
                  items: ["ANAMATH", "ANAMATH RECEIVED", "CREDIT", "CREDIT RECIEVED"]
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedAccountType = value),
                  validator: (value) => value == null ? 'Select account type' : null,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _updateBill,
                      icon: const Icon(Icons.update),
                      label: const Text("Update"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                    ElevatedButton.icon(
                      onPressed: _deleteBill,
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}