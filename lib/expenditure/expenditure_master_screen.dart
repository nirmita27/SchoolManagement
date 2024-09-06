import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpenditureMasterScreen extends StatefulWidget {
  @override
  _ExpenditureMasterScreenState createState() => _ExpenditureMasterScreenState();
}

class _ExpenditureMasterScreenState extends State<ExpenditureMasterScreen> {
  List<Map<String, dynamic>> _expenditureMasterItems = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenditureMasterItems();
  }

  Future<void> _fetchExpenditureMasterItems() async {
    var response = await http.get(Uri.parse('http://localhost:3000/expenditure-master'));
    if (response.statusCode == 200) {
      setState(() {
        _expenditureMasterItems = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to fetch expenditure master items');
    }
  }

  Future<void> _addExpenditureMasterItem(String description) async {
    var response = await http.post(
      Uri.parse('http://localhost:3000/expenditure-master'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'item_description': description}),
    );

    if (response.statusCode == 201) {
      _fetchExpenditureMasterItems();
    } else {
      print('Failed to add expenditure master item');
    }
  }

  Future<void> _editExpenditureMasterItem(int id, String description) async {
    var response = await http.patch(
      Uri.parse('http://localhost:3000/expenditure-master/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'item_description': description}),
    );

    if (response.statusCode == 200) {
      _fetchExpenditureMasterItems();
    } else {
      print('Failed to edit expenditure master item');
    }
  }

  Future<void> _deleteExpenditureMasterItem(int id) async {
    var response = await http.delete(Uri.parse('http://localhost:3000/expenditure-master/$id'));

    if (response.statusCode == 200) {
      _fetchExpenditureMasterItems();
    } else {
      print('Failed to delete expenditure master item');
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> item) async {
    TextEditingController descriptionController = TextEditingController(text: item['item_description']);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Expenditure Master Item'),
          content: TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _editExpenditureMasterItem(item['item_id'], descriptionController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddDialog() async {
    TextEditingController descriptionController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Expenditure Master Item'),
          content: TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addExpenditureMasterItem(descriptionController.text);
                Navigator.of(context).pop();
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
        title: Text('Expenditure Master'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showAddDialog,
              child: Text('Add New Item'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _expenditureMasterItems.length,
                itemBuilder: (context, index) {
                  final item = _expenditureMasterItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['item_description']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showEditDialog(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteExpenditureMasterItem(item['item_id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
