import 'package:event_management_app/widget/cart_badge.dart';
import 'package:event_management_app/widget/category_chips.dart';
import 'package:event_management_app/widget/food_grid.dart';
import 'package:flutter/material.dart';


class FoodScreen extends StatelessWidget {
  const FoodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(

        title: const Text('Food Menu'),
        actions: const [CartBadge()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade50,
              Colors.brown.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            const CategoryChips(),
            Expanded(child: FoodGrid()),
          ],
        ),
      ),
    );
  }
}