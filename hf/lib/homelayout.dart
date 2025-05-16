import 'package:flutter/material.dart';
import 'package:hfapp/customer.dart';
import 'package:hfapp/customerdetails.dart';
import 'package:hfapp/jsonupload.dart';
import 'package:hfapp/login.dart';
import 'package:hfapp/payments.dart';
import 'package:hfapp/settlement.dart';
import 'package:hfapp/student.dart';
import 'package:hfapp/studentdetails.dart';
import 'package:hfapp/underprogress.dart';

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
    'Customers': ['Customer', 'Customer Details'],
    'Bills': ['Bill', 'Bill Details'],
    'Accounts': ['Settlement'],
    'Admin': ['Upload Data'],
    'Logout': [],
  };

  Widget getTabContent() {
    if (selectedSubTab == 'Customer') {
      return const CustomerWidget();
    }
    if (selectedSubTab == 'Customer Details') {
      return const CustomerDetailsWidget();
    }
    if (selectedSubTab == 'Bill') {
      return const UnderProgressWidget();
    }
    if (selectedSubTab == 'Bill Details') {
      return const UnderProgressWidget();
    }
    if (selectedSubTab == 'Settlement') {
      return const SettlementFormWidget();
    }
    if (selectedSubTab == 'Upload Data') {
      return const UnderProgressWidget();
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
