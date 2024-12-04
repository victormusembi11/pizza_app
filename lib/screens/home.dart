import 'package:flutter/material.dart';

import 'package:pizza_app/components/pizza_item.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  void _addToCart(String pizzaName) {
    // Implement your add-to-cart functionality here
    print('$pizzaName added to cart!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(
        children: [
          PizzaItem(
            imageUrl:
                'https://i0.wp.com/daddioskitchen.com/wp-content/uploads/2023/01/IMG-5299.jpg?fit=800%2C800&ssl=1',
            name: 'Pepperoni Pizza',
            description: 'A delicious pepperoni pizza with mozzarella cheese.',
            price: 12.99,
            onAddToCart: () => _addToCart('Pepperoni Pizza'),
          ),
          PizzaItem(
            imageUrl:
                'https://i0.wp.com/saturdayswithfrank.com/wp-content/uploads/marg-pizza-f.jpg?fit=2500%2C1249&ssl=1',
            name: 'Margherita Pizza',
            description:
                'Classic Margherita with fresh basil and tomato sauce.',
            price: 10.99,
            onAddToCart: () => _addToCart('Margherita Pizza'),
          ),
          PizzaItem(
            imageUrl:
                'https://i0.wp.com/www.slapyodaddybbq.com/wp-content/uploads/BBQChickenPizza-foodgawker.jpg?fit=600%2C600&ssl=1',
            name: 'BBQ Chicken Pizza',
            description: 'Topped with BBQ chicken, red onions, and cilantro.',
            price: 14.99,
            onAddToCart: () => _addToCart('BBQ Chicken Pizza'),
          ),
        ],
      ),
    );
  }
}
