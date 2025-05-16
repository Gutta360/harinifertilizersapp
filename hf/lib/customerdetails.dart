import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDetailsWidget extends StatefulWidget {
  const CustomerDetailsWidget({super.key});

  @override
  State<CustomerDetailsWidget> createState() => _CustomerDetailsWidgetState();
}

class _CustomerDetailsWidgetState extends State<CustomerDetailsWidget> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  String? _selectedCustomerName; // full name string
  Map<String, Map<String, dynamic>> _customerMap = {}; // "surname name" => {...}

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final snapshot = await FirebaseFirestore.instance.collection('customers').get();

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

  Future<void> _updatePhone() async {
    if (_formKey.currentState!.validate() && _selectedCustomerName != null) {
      final docId = _customerMap[_selectedCustomerName]!['docId'];
      await FirebaseFirestore.instance.collection('customers').doc(docId).update({
        'phonenumber': _phoneController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number updated')),
      );
    }
  }

  Future<void> _deleteCustomer() async {
    if (_selectedCustomerName != null) {
      final docId = _customerMap[_selectedCustomerName]!['docId'];
      await FirebaseFirestore.instance.collection('customers').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted')),
      );
      setState(() {
        _selectedCustomerName = null;
        _phoneController.clear();
      });
      _fetchCustomers();
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
          image: AssetImage("assets/bg2.jpg"),
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
                  'Customer Details',
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
                        dropdownSearchDecoration:
                            _inputDecoration("Name", Icons.person_outline),
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
                          final phone = _customerMap[item]!['phonenumber'] ?? '';
                          return ListTile(
                            tileColor:
                                isSelected ? Colors.orange.shade100 : null,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item, style: const TextStyle(color: Colors.black)),
                                Text(phone, style: const TextStyle(color: Colors.black)),
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
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomerName = value;
                          _phoneController.text = value != null
                              ? _customerMap[value]!['phonenumber'] ?? ''
                              : '';
                        });
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? "Name is required" : null,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _inputDecoration("Phone Number", Icons.phone_android_outlined),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) =>
                          value == null || value.length != 10 ? 'Enter 10-digit phone' : null,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _updatePhone,
                          icon: const Icon(Icons.update),
                          label: const Text("Update"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton.icon(
                          onPressed: _deleteCustomer,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text("Delete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
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