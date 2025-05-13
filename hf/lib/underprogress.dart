import 'package:flutter/material.dart';

class UnderProgressWidget extends StatelessWidget {
  const UnderProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Development under progress',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}