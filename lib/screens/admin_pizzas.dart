import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPizzasPage extends StatelessWidget {
  const AdminPizzasPage({super.key});

  Future<void> _addPizza(BuildContext context) async {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priceController = TextEditingController();
    final _imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Pizza'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Pizza Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = _nameController.text;
                final description = _descriptionController.text;
                final price = _priceController.text;
                final imageUrl = _imageUrlController.text;

                if (name.isEmpty ||
                    description.isEmpty ||
                    price.isEmpty ||
                    imageUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                final url = Uri.parse('http://localhost:5000/pizzas/post.php');
                final response = await http.post(url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'name': name,
                      'description': description,
                      'price': double.parse(price),
                      'imageUrl': imageUrl,
                    }));

                final responseData = jsonDecode(response.body);

                if (response.statusCode == 200 &&
                    responseData['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pizza added successfully')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add pizza')),
                  );
                }
              },
              child: const Text('Add Pizza'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Manage Pizzas',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPizza(context),
        tooltip: 'Add Pizza',
        child: const Icon(Icons.add),
      ),
    );
  }
}
