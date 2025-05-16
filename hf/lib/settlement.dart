import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'pdf.dart';

class SettlementFormWidget extends StatefulWidget {
  const SettlementFormWidget({super.key});

  @override
  State<SettlementFormWidget> createState() => _SettlementFormWidgetState();
}

class _SettlementFormWidgetState extends State<SettlementFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  Map<String, Map<String, dynamic>> _customerMap = {}; // fullName → {id, phone}
  String? _selectedCustomerName; // fullName like "Gutta Ram"

  List<Map<String, dynamic>> _fetchedTransactions = [];
  List<Map<String, dynamic>> _customers = [];

  String? _selectedCustomerId;
  String? _selectedDisplayName;
  DateTime _selectedDate = DateTime.now();
  String? _accountType;
  String? _interest;

  double? _total;
  double? _interestValue;
  double? _totalWithInterest;

  bool _showTallyTable = false;

  List<String> _accountTypes = [
    "ANAMATH",
    "ANAMATH RECEIVED",
    "CREDIT",
    "CREDIT RECEIVED"
  ];

  List<String> _interestRates =
      List.generate(18, (i) => "${(i * 0.5).toStringAsFixed(1)} %");

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _fetchCustomers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("customers").get();

    final Map<String, Map<String, dynamic>> customerMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final fullName = "${data['surname']} ${data['name']}";
      customerMap[fullName] = {
        "id": doc.id,
        "phonenumber": data['phonenumber'] ?? '',
      };
    }

    setState(() {
      _customerMap = customerMap;
    });
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }

  Future<void> _calculateSettlement() async {
    if (_selectedDisplayName == null ||
        _accountType == null ||
        _interest == null) return;

    final query = await FirebaseFirestore.instance
        .collection("transactions")
        .where("name", isEqualTo: _selectedDisplayName)
        .where("type", isEqualTo: _accountType)
        .get();

    _fetchedTransactions = query.docs.map((doc) => doc.data()).toList();

    double total = 0;
    double interest = 0;
    DateTime settlementDate = _selectedDate;
    double rate =
        double.parse(_interest!.replaceAll('%', '').trim()) / 100 / 30;

    for (var doc in query.docs) {
      final data = doc.data();
      final amount = double.tryParse(data["billamount"].toString()) ?? 0;
      final date = DateTime.tryParse(data["date"].toString()) ?? settlementDate;
      int days = settlementDate.difference(date).inDays;
      double docInterest = amount * rate * days;

      total += amount;
      interest += docInterest;
    }

    setState(() {
      _total = total;
      _interestValue = interest;
      _totalWithInterest = total + interest;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settlement Form"),
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
            padding: const EdgeInsets.all(16.0),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownSearch<String>(
                      items: _customerMap.keys.toList(),
                      selectedItem: _selectedCustomerName,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration:
                            _inputDecoration("Customer Name"),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            labelText: "Search Customer",
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
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomerName = value;
                          _selectedDisplayName = value; // for PDF
                          _selectedCustomerId =
                              value != null ? _customerMap[value]!['id'] : null;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? "Customer is required"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: _inputDecoration("Settlement Date").copyWith(
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _accountType,
                      items: _accountTypes
                          .map((type) => DropdownMenuItem<String>(
                              value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) => setState(() => _accountType = val),
                      decoration: _inputDecoration("Account Type"),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _interest,
                      items: _interestRates
                          .map((rate) => DropdownMenuItem<String>(
                              value: rate, child: Text(rate)))
                          .toList(),
                      onChanged: (val) => setState(() => _interest = val),
                      decoration: _inputDecoration("Interest"),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calculate),
                          label: const Text("Calculate"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _calculateSettlement,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.table_chart),
                          label: const Text("Tally"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (_fetchedTransactions.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please calculate first.")),
                              );
                            } else {
                              setState(() {
                                _showTallyTable = !_showTallyTable;
                              });
                            }
                          },
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.print),
                          label: const Text("Print"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            if (_selectedDisplayName == null ||
                                _interest == null ||
                                _accountType == null ||
                                _dateController.text.isEmpty ||
                                _fetchedTransactions.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Please calculate first before printing.")),
                              );
                              return;
                            }

                            await generateAndPrintPdf(
                              context: context,
                              customerName: _selectedDisplayName!,
                              interestRate: _interest!,
                              settlementDate: _dateController.text,
                              accountType: _accountType!,
                              transactions: _fetchedTransactions,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    if (_total != null &&
                        _interestValue != null &&
                        _totalWithInterest != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Bill Amount:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(_total!.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace')),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Interest:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(_interestValue!.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace')),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Payment Amount:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(_totalWithInterest!.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace')),
                        ],
                      ),
                    ],
                    if (_showTallyTable) ...[
                      const SizedBox(height: 24),
                      const Text("Tally Records",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 300,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("S.No")),
                                DataColumn(label: Text("Bill Date")),
                                DataColumn(label: Text("Bill No")),
                                DataColumn(label: Text("Bill Amount")),
                                DataColumn(label: Text("Interest")),
                                DataColumn(label: Text("Total")),
                              ],
                              rows: _fetchedTransactions
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key + 1;
                                final data = entry.value;

                                final billDate = data["date"] ?? '';
                                final billNo = data["billno"] ?? '';
                                final billAmt = double.tryParse(
                                        data["billamount"].toString()) ??
                                    0;
                                final billDateParsed =
                                    DateTime.tryParse(billDate.toString());
                                final formattedDate = billDateParsed != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(billDateParsed)
                                    : billDate.toString();

                                final rate = double.parse(
                                        _interest!.replaceAll('%', '').trim()) /
                                    100 /
                                    30;
                                final days = _selectedDate
                                    .difference(billDateParsed ?? _selectedDate)
                                    .inDays;
                                final interest = billAmt * rate * days;
                                final total = billAmt + interest;

                                return DataRow(
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      return index % 2 == 0
                                          ? const Color(
                                              0xFFFFF8E1) // Cream for even rows
                                          : Colors.white; // White for odd rows
                                    },
                                  ),
                                  cells: [
                                    DataCell(Text(index.toString())),
                                    DataCell(Text(formattedDate)),
                                    DataCell(Text(billNo.toString())),
                                    DataCell(Text(billAmt.toStringAsFixed(2))),
                                    DataCell(Text(interest.toStringAsFixed(2))),
                                    DataCell(Text(total.toStringAsFixed(2))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ]
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
