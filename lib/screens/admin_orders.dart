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
                          onPressed: () {
                            // Add functionality to update order status here
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
  final String pizzaName;
  final int quantity;
  final String price;
  final String description;

  OrderItem({
    required this.pizzaName,
    required this.quantity,
    required this.price,
    required this.description,
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
