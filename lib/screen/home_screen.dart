import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screen/new_item_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> _groceryItems = [];

  @override
  void initState() {
    super.initState();
    // _loadItem();
  }

  
  void _addItem() async {
    final item = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NewItemScreen()));

    setState(() {
      _groceryItems.add(item);
    });
  }

  void removeGroceryItem(GroceryItem groceryItem) {
    setState(() {
      _groceryItems.remove(groceryItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List App'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: _groceryItems.isEmpty
          ? const Center(
              child: Text('Grocery Items is Empty'),
            )
          : ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (context, index) {
                final groceryItem = _groceryItems[index];
                return Dismissible(
                  key: ValueKey(groceryItem.id),
                  onDismissed: (direction) {
                    removeGroceryItem(groceryItem);
                  },
                  child: ListTile(
                    leading: Container(
                      height: 24,
                      width: 24,
                      color: groceryItem.category.color,
                    ),
                    title: Text(groceryItem.name),
                    trailing: Text(groceryItem.quantity.toString()),
                  ),
                );
              }),
    );
  }
}
