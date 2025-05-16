import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class CustomerWidget extends StatefulWidget {
  const CustomerWidget({super.key});

  @override
  State<CustomerWidget> createState() => _CustomerWidgetState();
}

class _CustomerWidgetState extends State<CustomerWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  Future<bool> _isDuplicateCustomer(String name, String surname, String phone) async {
    final normalizedName = name.trim().toLowerCase();
    final normalizedSurname = surname.trim().toLowerCase();

    final query1 = await FirebaseFirestore.instance
        .collection('customers')
        .get();

    final nameSurnameExists = query1.docs.any((doc) =>
        (doc['name'] as String).toLowerCase() == normalizedName &&
        (doc['surname'] as String).toLowerCase() == normalizedSurname);

    if (nameSurnameExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This Name + Surname already exists (case-insensitive).')),
      );
      return true;
    }

    final phoneExists = query1.docs.any((doc) =>
        (doc['phonenumber'] as String) == phone);

    if (phoneExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number already exists.')),
      );
      return true;
    }

    return false;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final phone = _phoneController.text.trim();

    setState(() => _isSubmitting = true);

    try {
      final isDuplicate = await _isDuplicateCustomer(name, surname, phone);

      if (!isDuplicate) {
        await FirebaseFirestore.instance.collection('customers').add({
          'name': name,
          'surname': surname,
          'phonenumber': phone,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer added successfully')),
        );
        _formKey.currentState!.reset();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() => _isSubmitting = false);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black87, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  'Customer Form',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration("Name", Icons.person_outline),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                      ],
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter name' : null,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _surnameController,
                      decoration: _inputDecoration("Surname", Icons.badge_outlined),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                      ],
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter surname' : null,
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
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: Text(_isSubmitting ? 'Checking...' : 'Add'),
                      ),
                    ),
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