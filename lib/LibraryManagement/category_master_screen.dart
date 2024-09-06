import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryMasterScreen extends StatefulWidget {
  @override
  _CategoryMasterScreenState createState() => _CategoryMasterScreenState();
}

class _CategoryMasterScreenState extends State<CategoryMasterScreen> {
  List categories = [];

  @override
  void initState() {
    super.initState();
    _fetchBookCategories();
  }

  Future<void> _fetchBookCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/book-categories'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched book categories: $data'); // Debug print
      setState(() {
        categories = data;
      });
    } else {
      throw Exception('Failed to load book categories');
    }
  }

  Future<void> _addBookCategory(String bookCategoryName, int orderNo) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/book-categories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'book_category_name': bookCategoryName, 'order_no': orderNo}),
    );

    if (response.statusCode == 201) {
      _fetchBookCategories();
    } else {
      throw Exception('Failed to add book category');
    }
  }

  Future<void> _updateBookCategory(int id, String bookCategoryName, int orderNo) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/book-categories/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'book_category_name': bookCategoryName, 'order_no': orderNo}),
    );

    if (response.statusCode == 200) {
      _fetchBookCategories();
    } else {
      throw Exception('Failed to update book category');
    }
  }

  Future<void> _deleteBookCategory(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/book-categories/$id'));

    if (response.statusCode == 204) {
      _fetchBookCategories();
    } else {
      throw Exception('Failed to delete book category');
    }
  }

  void _showForm({int? id, String? bookCategoryName, int? orderNo}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(
        text: bookCategoryName ?? '');
    final TextEditingController orderNoController = TextEditingController(
        text: orderNo?.toString() ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Category' : 'Edit Category'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Book Category Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: orderNoController,
                  decoration: InputDecoration(labelText: 'Order No'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an order number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(id == null ? 'Add' : 'Update'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (id == null) {
                    _addBookCategory(
                        nameController.text, int.parse(orderNoController.text));
                  } else {
                    _updateBookCategory(id, nameController.text,
                        int.parse(orderNoController.text));
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Master'),
        backgroundColor: Colors.blueAccent,
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: Text(category['book_category_name'] ?? 'N/A'),
              subtitle: Text(
                  'Order No: ${category['order_no']?.toString() ?? 'N/A'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () =>
                        _showForm(
                          id: category['id'],
                          bookCategoryName: category['book_category_name'],
                          orderNo: category['order_no'],
                        ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteBookCategory(category['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showForm(),
      ),
    );
  }
}