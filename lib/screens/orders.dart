import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Orders'),
      ),
      body: const Center(
        child: Text(
          'Orders Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
