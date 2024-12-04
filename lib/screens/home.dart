import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:pizza_app/components/pizza_item.dart';
import './cart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> pizzas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPizzas();
  }

  Future<void> _fetchPizzas() async {
    final url = Uri.parse('http://localhost:5000/pizzas/get.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pizzas = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load pizzas')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void _addToCart(String pizzaName) {
    // Implement your add-to-cart functionality here
    print('$pizzaName added to cart!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pizzas.length,
              itemBuilder: (ctx, index) {
                final pizza = pizzas[index];
                return PizzaItem(
                  imageUrl: pizza['imageUrl'],
                  name: pizza['name'],
                  description: pizza['description'],
                  price: pizza['price'],
                  onAddToCart: () => _addToCart(pizza['name']),
                );
              },
            ),
    );
  }
}
