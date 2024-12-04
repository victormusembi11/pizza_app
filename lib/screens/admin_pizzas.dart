import 'package:flutter/material.dart';

class AdminPizzasPage extends StatelessWidget {
  const AdminPizzasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Manage Pizzas',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
