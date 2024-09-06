import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StaffCategoryMasterScreen extends StatefulWidget {
  @override
  _StaffCategoryMasterScreenState createState() => _StaffCategoryMasterScreenState();
}

class _StaffCategoryMasterScreenState extends State<StaffCategoryMasterScreen> {
  List<dynamic> staffCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaffCategories();
  }

  Future<void> _fetchStaffCategories() async {
    final url = Uri.parse('http://localhost:3000/staff-categories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          staffCategories = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load staff categories');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch staff categories. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showCreateEditDialog({Map<String, dynamic>? category}) {
    final _nameController = TextEditingController(text: category?['staff_category_name']);
    final _orderNoController = TextEditingController(text: category?['order_no']?.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(category == null ? 'Add Staff Category' : 'Edit Staff Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Staff Category'),
              ),
              TextField(
                controller: _orderNoController,
                decoration: InputDecoration(labelText: 'Order No'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text(category == null ? 'Add' : 'Save'),
            onPressed: () {
              final name = _nameController.text;
              final orderNo = int.parse(_orderNoController.text);

              if (category == null) {
                _createStaffCategory(name, orderNo);
              } else {
                _editStaffCategory(category['id'], name, orderNo);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createStaffCategory(String name, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/staff-categories');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'staff_category_name': name,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 201) {
        _fetchStaffCategories();
      } else {
        throw Exception('Failed to create staff category');
      }
    } catch (error) {
      _showErrorDialog('Failed to create staff category. Please try again.');
    }
  }

  void _editStaffCategory(int id, String name, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/staff-categories/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'staff_category_name': name,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 200) {
        _fetchStaffCategories();
      } else {
        throw Exception('Failed to edit staff category');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit staff category. Please try again.');
    }
  }

  void _deleteStaffCategory(int id) async {
    final url = Uri.parse('http://localhost:3000/staff-categories/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchStaffCategories();
      } else {
        throw Exception('Failed to delete staff category');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete staff category. Please try again.');
    }
  }

  Widget _buildStaffCategoryTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Staff Category Name')),
        DataColumn(label: Text('Order No')),
        DataColumn(label: Text('Actions')),
      ],
      rows: staffCategories
          .asMap()
          .map((index, category) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(category['staff_category_name'])),
          DataCell(Text(category['order_no'].toString())),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(category: category);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteStaffCategory(category['id']);
                },
              ),
            ],
          )),
        ]),
      ))
          .values
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Category Master'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildStaffCategoryTable(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateEditDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}
