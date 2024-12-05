import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class OrderItem extends StatelessWidget {
  final String pizzaName;
  final String description;
  final int quantity;
  final double price;

  const OrderItem({
    super.key,
    required this.pizzaName,
    required this.description,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(pizzaName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "$description\nQuantity: $quantity",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text("\$${(price * quantity).toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Future<List<dynamic>> fetchUserOrders() async {
    final userId = context.read<AuthProvider>().userId;

    final response = await http.get(
      Uri.parse('http://localhost:5000/order/get.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['data']; // This will contain the list of orders
      } else {
        throw Exception('Failed to load orders');
      }
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Orders'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('You have no orders yet'),
            );
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ExpansionTile(
                  title: Text('Order #${order['order_id']}'),
                  subtitle: Text('Status: ${order['status']}'),
                  children: [
                    Column(
                      children: [
                        Text("Order Created At: ${order['created_at']}"),
                        // You can add another API call here to fetch the items for the order if needed
                      ],
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
