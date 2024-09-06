import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubCategoryMasterScreen extends StatefulWidget {
  @override
  _SubCategoryMasterScreenState createState() => _SubCategoryMasterScreenState();
}

class _SubCategoryMasterScreenState extends State<SubCategoryMasterScreen> {
  List subcategories = [];

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/subcategories'));

    if (response.statusCode == 200) {
      setState(() {
        subcategories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load subcategories');
    }
  }

  Future<void> _addSubCategory(String name, int orderNo) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/subcategories'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'name': name, 'order_no': orderNo}),
    );

    if (response.statusCode == 201) {
      _fetchSubCategories();
    } else {
      throw Exception('Failed to add subcategory');
    }
  }

  Future<void> _updateSubCategory(int id, String name, int orderNo) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/subcategories/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({'name': name, 'order_no': orderNo}),
    );

    if (response.statusCode == 200) {
      _fetchSubCategories();
    } else {
      throw Exception('Failed to update subcategory');
    }
  }

  Future<void> _deleteSubCategory(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/subcategories/$id'));

    if (response.statusCode == 204) {
      _fetchSubCategories();
    } else {
      throw Exception('Failed to delete subcategory');
    }
  }

  void _showForm({int? id, String? name, int? orderNo}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(text: name);
    final TextEditingController orderNoController = TextEditingController(text: orderNo?.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Sub Category' : 'Edit Sub Category'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
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
                    _addSubCategory(nameController.text, int.parse(orderNoController.text));
                  } else {
                    _updateSubCategory(id, nameController.text, int.parse(orderNoController.text));
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
        title: Text('Sub Category Master'),
        backgroundColor: Colors.pink,
      ),
      body: ListView.builder(
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subcategories[index]['name']),
            subtitle: Text('Order No: ${subcategories[index]['order_no']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showForm(
                    id: subcategories[index]['id'],
                    name: subcategories[index]['name'],
                    orderNo: subcategories[index]['order_no'],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteSubCategory(subcategories[index]['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        onPressed: () => _showForm(),
      ),
    );
  }
}
