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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final List<GroceryItem> loadedItems = [];
    final url = Uri.https(
        'shopping-list-7e6d2-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json');

    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> shopListItems = jsonDecode(response.body);
      for (final item in shopListItems.entries) {
        final category = categories.entries.firstWhere(
          (catItem) {
            return catItem.value.title == item.value['category'];
          },
        ).value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
        setState(() {
          _groceryItems = loadedItems;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = "Error Fetching items";
      });
    }
  }

  void _addItem() async {
    final item = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NewItemScreen()));

    if (item == null) {
      return;
    }
    setState(() {
      _groceryItems.add(item);
    });
  }

  void removeGroceryItem(GroceryItem groceryItem) async {
    final index = _groceryItems.indexOf(groceryItem);
    setState(() {
      _groceryItems.remove(groceryItem);
    });
    final url = Uri.https(
        'shopping-list-7e6d2-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${groceryItem.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _errorMessage = 'Error ${response.reasonPhrase}';
      setState(() {
        _groceryItems.insert(index, groceryItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Grocery Items is Empty'),
    );

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      content = Center(
        child: Text(_errorMessage!),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
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
          });
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Shopping List App'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
