import 'package:event_management_app/screeen/food_details_screen.dart';
import 'package:event_management_app/widget/food_item.dart';
import 'package:flutter/material.dart';


class FoodGrid extends StatelessWidget {
   FoodGrid({Key? key}) : super(key: key);

  // Sample food items - in a real app, this would come from a database or API
  final List<FoodItem> foodItems = [
    FoodItem(
      id: '1',
      name: 'Classic Burger',
      description: 'Juicy beef patty with fresh vegetables and special sauce',
      price: 250,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
      category: 'Burgers',
    ),
    FoodItem(
      id: '2',
      name: 'Margherita Pizza',
      description: 'Fresh tomatoes, mozzarella, and basil on a crispy crust',
      price: 450,
      imageUrl: 'https://images.unsplash.com/photo-1604382355076-af4b0eb60143?w=500',
      category: 'Pizza',
    ),
    FoodItem(
      id: '3',
      name: 'Chocolate Shake',
      description: 'Rich and creamy chocolate milkshake',
      price: 180,
      imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500',
      category: 'Drinks',
    ),
    FoodItem(
      id: '4',
      name: 'Cheesecake',
      description: 'New York style cheesecake with berry compote',
      price: 320,
      imageUrl: 'https://images.unsplash.com/photo-1508737027454-e6454ef45afd?w=500',
      category: 'Desserts',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: foodItems.length,
      itemBuilder: (context, index) {
        final food = foodItems[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FoodDetailsScreen(food: food),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Hero(
                    tag: food.id,
                    child: Image.network(
                      food.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${food.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}