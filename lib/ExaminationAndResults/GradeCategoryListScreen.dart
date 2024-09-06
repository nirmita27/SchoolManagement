import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GradeCategoryListScreen extends StatefulWidget {
  @override
  _GradeCategoryListScreenState createState() => _GradeCategoryListScreenState();
}

class _GradeCategoryListScreenState extends State<GradeCategoryListScreen> {
  List gradeCategories = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchGradeCategories();
  }

  Future<void> fetchGradeCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/grade-categories'));
    if (response.statusCode == 200) {
      setState(() {
        gradeCategories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load grade categories');
    }
  }

  void _showAddGradeCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditGradeCategoryDialog(
          onSave: (gradeCategory) {
            addGradeCategory(gradeCategory);
          },
        );
      },
    );
  }

  Future<void> addGradeCategory(Map<String, dynamic> gradeCategory) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/grade-categories'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(gradeCategory),
    );
    if (response.statusCode == 201) {
      fetchGradeCategories();
    } else {
      throw Exception('Failed to add grade category');
    }
  }

  Future<void> editGradeCategory(int id, Map<String, dynamic> gradeCategory) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/grade-categories/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(gradeCategory),
    );
    if (response.statusCode == 200) {
      fetchGradeCategories();
    } else {
      throw Exception('Failed to edit grade category');
    }
  }

  Future<void> deleteGradeCategory(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/grade-categories/$id'),
    );
    if (response.statusCode == 200) {
      fetchGradeCategories();
    } else {
      throw Exception('Failed to delete grade category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Category List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildPaginationControls(),
            SizedBox(height: 10),
            _buildDataTable(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGradeCategoryDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                currentPage = 1;
              });
            },
            decoration: InputDecoration(
              labelText: 'Search Grade Category',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    final int totalItems = gradeCategories.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Page $currentPage of $totalPages'),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: currentPage > 1
                  ? () {
                setState(() {
                  currentPage--;
                });
              }
                  : null,
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: currentPage < totalPages
                  ? () {
                setState(() {
                  currentPage++;
                });
              }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    final filteredGradeCategories = gradeCategories
        .where((gradeCategory) =>
        gradeCategory['name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    final int totalItems = filteredGradeCategories.length;
    final int startItem = (currentPage - 1) * itemsPerPage;
    final int endItem = startItem + itemsPerPage;
    final List displayedGradeCategories = filteredGradeCategories.sublist(
      startItem,
      endItem > totalItems ? totalItems : endItem,
    );

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('S.No.')),
            DataColumn(label: Text('Grade Category Name')),
            DataColumn(label: Text('Max Value')),
            DataColumn(label: Text('Order No')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(
            displayedGradeCategories.length,
                (index) {
              final gradeCategory = displayedGradeCategories[index];
              return DataRow(
                cells: [
                  DataCell(Text('${startItem + index + 1}')),
                  DataCell(Text(gradeCategory['name'])),
                  DataCell(Text(gradeCategory['max_value'].toString())),
                  DataCell(Text(gradeCategory['order_no'].toString())),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditGradeCategoryDialog(gradeCategory);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteGradeCategory(gradeCategory['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showEditGradeCategoryDialog(Map<String, dynamic> gradeCategory) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditGradeCategoryDialog(
          gradeCategory: gradeCategory,
          onSave: (updatedGradeCategory) {
            editGradeCategory(gradeCategory['id'], updatedGradeCategory);
          },
        );
      },
    );
  }
}

class AddEditGradeCategoryDialog extends StatefulWidget {
  final Map<String, dynamic>? gradeCategory;
  final Function(Map<String, dynamic>) onSave;

  AddEditGradeCategoryDialog({this.gradeCategory, required this.onSave});

  @override
  _AddEditGradeCategoryDialogState createState() => _AddEditGradeCategoryDialogState();
}

class _AddEditGradeCategoryDialogState extends State<AddEditGradeCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _maxValue;
  String? _orderNo;

  @override
  void initState() {
    super.initState();
    if (widget.gradeCategory != null) {
      _name = widget.gradeCategory!['name'];
      _maxValue = widget.gradeCategory!['max_value'].toString();
      _orderNo = widget.gradeCategory!['order_no'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.gradeCategory != null ? 'Edit Grade Category' : 'Add New Grade Category'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(labelText: 'Grade Category Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a grade category name';
                }
                return null;
              },
              onSaved: (value) {
                _name = value;
              },
            ),
            TextFormField(
              initialValue: _maxValue,
              decoration: InputDecoration(labelText: 'Max Value'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a max value';
                }
                return null;
              },
              onSaved: (value) {
                _maxValue = value;
              },
            ),
            TextFormField(
              initialValue: _orderNo,
              decoration: InputDecoration(labelText: 'Order No'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an order number';
                }
                return null;
              },
              onSaved: (value) {
                _orderNo = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave({
                'name': _name,
                'max_value': _maxValue,
                'order_no': _orderNo,
              });
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.gradeCategory != null ? 'Save' : 'Add'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
