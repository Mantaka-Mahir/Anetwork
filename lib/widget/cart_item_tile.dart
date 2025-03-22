import 'package:event_management_app/widget/cart_item.dart';
import 'package:flutter/material.dart';

import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  const CartItemTile({
    Key? key,
    required this.cartItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.food.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.food.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${cartItem.food.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    context.read<CartProvider>().updateQuantity(
                      cartItem.food.id,
                      cartItem.quantity - 1,
                    );
                  },
                ),
                Text(
                  cartItem.quantity.toString(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    context.read<CartProvider>().updateQuantity(
                      cartItem.food.id,
                      cartItem.quantity + 1,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}