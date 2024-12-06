import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  _AdminOrdersPageState createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  late Future<List<Order>> orders;

  @override
  void initState() {
    super.initState();
    orders = fetchOrders();
  }

  Future<List<Order>> fetchOrders() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/order/get_all.php'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((order) => Order.fromJson(order)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Method to update the order status
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/order/update_status.php'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'order_id': orderId,
        'status': newStatus,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        // If successful, show a success message and reload the orders
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Order status updated successfully.')));
        setState(() {
          orders = fetchOrders(); // Refresh the order list
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update order status.')));
      }
    } else {
      throw Exception('Failed to update order status');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Order>>(
        future: orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            List<Order> orderList = snapshot.data!;

            return ListView.builder(
              itemCount: orderList.length,
              itemBuilder: (context, index) {
                final order = orderList[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderId}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('Created at: ${order.createdAt}'),
                        Text('Status: ${order.status}'),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  Text('${item.quantity} x ${item.pizzaName}'),
                                  const SizedBox(width: 10),
                                  Text('${item.price}'),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            // Show a dialog to confirm the status update
                            String? selectedStatus = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Update Order Status'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        title: const Text('Pending'),
                                        onTap: () => Navigator.of(context)
                                            .pop('PENDING'),
                                      ),
                                      ListTile(
                                        title: const Text('Processing'),
                                        onTap: () => Navigator.of(context)
                                            .pop('PROCESSING'),
                                      ),
                                      ListTile(
                                        title: const Text('Completed'),
                                        onTap: () => Navigator.of(context)
                                            .pop('COMPLETED'),
                                      ),
                                      ListTile(
                                        title: const Text('Cancelled'),
                                        onTap: () => Navigator.of(context)
                                            .pop('CANCELLED'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            // If the user selects a status, update it
                            if (selectedStatus != null) {
                              await updateOrderStatus(
                                  order.orderId, selectedStatus);
                            }
                          },
                          child: const Text('Update Order Status'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Order model
class Order {
  final int orderId;
  final String createdAt;
  final String status;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.createdAt,
    required this.status,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['items'] as List;
    List<OrderItem> itemsList =
        itemsJson.map((item) => OrderItem.fromJson(item)).toList();

    return Order(
      orderId: json['order_id'],
      createdAt: json['created_at'],
      status: json['status'],
      items: itemsList,
    );
  }
}

// OrderItem model
class OrderItem {
  final String? pizzaName;
  final int? quantity;
  final String? price;
  final String? description;

  OrderItem({
    this.pizzaName,
    this.quantity,
    this.price,
    this.description,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      pizzaName: json['pizza_name'],
      quantity: json['quantity'],
      price: json['price'],
      description: json['description'],
    );
  }
}
