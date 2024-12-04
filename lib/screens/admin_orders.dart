import 'package:flutter/material.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Manage Orders',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
