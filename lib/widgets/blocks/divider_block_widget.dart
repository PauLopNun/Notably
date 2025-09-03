import 'package:flutter/material.dart';

class DividerBlockWidget extends StatelessWidget {
  const DividerBlockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        thickness: 2,
        color: Colors.grey[300],
      ),
    );
  }
}