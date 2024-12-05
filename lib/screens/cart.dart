import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class CartItem extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  final int quantity;

  const CartItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 50,
          height: 50,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
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

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<List<dynamic>> fetchCartItems() async {
    final userId = context.read<AuthProvider>().userId;

    final response = await http.get(
      Uri.parse('http://localhost:5000/cart/get.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['data'];
      } else {
        throw Exception('Failed to load cart items');
      }
    } else {
      throw Exception('Failed to fetch data from server');
    }
  }

  Future<void> makeOrder() async {
    // Replace with actual user ID from your auth provider
    final userId = context.read<AuthProvider>().userId;
    final cartItems = await fetchCartItems();

    // Prepare order data
    final orderData = {
      'user_id': userId,
      'cart_items': cartItems.map((item) {
        return {
          'cart_id': item['cart_id'],
          'quantity': item['quantity'],
        };
      }).toList(),
    };

    // Send POST request to create the order
    final response = await http.post(
      Uri.parse('http://localhost:5000/order/post.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        // Optionally navigate to the order details or home screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to place order')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error placing order')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchCartItems(),
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
              child: Text('Your cart is empty'),
            );
          } else {
            final cartItems = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItem(
                        name: item['pizza_name'],
                        imageUrl: item['imageUrl'],
                        description: item['description'],
                        price: double.parse(item['price']),
                        quantity: int.parse(item['quantity']),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: makeOrder, // Call makeOrder() when pressed
                    child: const Text('Make Order'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
