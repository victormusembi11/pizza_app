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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Add New Pizza', style: TextStyle(fontSize: 24)),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                      _nameController, 'Pizza Name', Icons.local_pizza),
                  const SizedBox(height: 10),
                  _buildTextField(
                      _descriptionController, 'Description', Icons.description),
                  const SizedBox(height: 10),
                  _buildTextField(_priceController, 'Price', Icons.attach_money,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  _buildTextField(
                      _imageUrlController, 'Image URL', Icons.image),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
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
              child: const Text('Add Pizza', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  // Helper function to build input fields with icons
  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.green),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      keyboardType: keyboardType,
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
