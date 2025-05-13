import 'package:flutter/material.dart';
import 'package:littleflower/jsonupload.dart';
import 'package:littleflower/login.dart';
import 'package:littleflower/payments.dart';
import 'package:littleflower/student.dart';
import 'package:littleflower/studentdetails.dart';

class HomeLayoutWidget extends StatefulWidget {
  const HomeLayoutWidget({super.key});

  @override
  _HomeLayoutWidgetState createState() => _HomeLayoutWidgetState();
}

class _HomeLayoutWidgetState extends State<HomeLayoutWidget> {
  String expandedTab = 'Home';
  String selectedSubTab = 'Dashboard';

  final Map<String, List<String>> subTabs = {
    'Home': ['Dashboard'],
    'Student': ['Student', 'Student Details'],
    'Staff': ['Staff', 'Staff Details'],
    'Accounts': ['Income', 'Outgoing'],
    'Inventory': ['Item', 'Item Details'],
    'Admin': ['Upload Data'],
    'Logout': [],
  };

  Widget getTabContent() {
    if (selectedSubTab == 'Student') {
      return const StudentFormWidget();
    }
    if (selectedSubTab == 'Student Details') {
      return const StudentDetailsWidget();
    }
    if (selectedSubTab == 'Income') {
      return const PaymentFormWidget();
    }
    if (selectedSubTab == 'Upload Data') {
      return JsonUploadWidget();
    }
    return Center(
      child: Text(
        'Showing content for: $selectedSubTab',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/creamatte.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              children: subTabs.keys.map((tab) {
                if (tab == 'Logout') {
                  return ListTile(
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    leading: const Icon(Icons.logout, color: Colors.red),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const NewLoginPage()),
                      );
                    },
                  );
                }

                bool isExpanded = expandedTab == tab;
                return ExpansionTile(
                  initiallyExpanded: isExpanded,
                  title: Text(
                    tab,
                    style: TextStyle(
                      fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
                      color: Colors.blueGrey,
                    ),
                  ),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      expandedTab = tab;
                      selectedSubTab = subTabs[tab]!.first;
                    });
                  },
                  children: subTabs[tab]!
                      .map(
                        (subTab) => ListTile(
                          title: Text(
                            subTab,
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                          selected: selectedSubTab == subTab,
                          onTap: () {
                            setState(() {
                              selectedSubTab = subTab;
                              expandedTab = tab;
                            });
                          },
                        ),
                      )
                      .toList(),
                );
              }).toList(),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/creamatte.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: getTabContent(),
          ),
        ],
      ),
    );
  }
}
