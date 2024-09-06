import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GradeListScreen extends StatefulWidget {
  @override
  _GradeListScreenState createState() => _GradeListScreenState();
}

class _GradeListScreenState extends State<GradeListScreen> {
  List grades = [];
  List categories = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchGrades();
    fetchCategories();
  }

  Future<void> fetchGrades() async {
    final response = await http.get(Uri.parse('http://localhost:3000/grades'));
    if (response.statusCode == 200) {
      setState(() {
        grades = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load grades');
    }
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/grade-categories'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  void _showAddGradeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditGradeDialog(
          categories: categories,
          onSave: (grade) {
            addGrade(grade);
          },
        );
      },
    );
  }

  Future<void> addGrade(Map<String, dynamic> grade) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/grades'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(grade),
    );
    if (response.statusCode == 201) {
      fetchGrades();
    } else {
      throw Exception('Failed to add grade');
    }
  }

  Future<void> editGrade(int id, Map<String, dynamic> grade) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/grades/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(grade),
    );
    if (response.statusCode == 200) {
      fetchGrades();
    } else {
      throw Exception('Failed to edit grade');
    }
  }

  Future<void> deleteGrade(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/grades/$id'),
    );
    if (response.statusCode == 200) {
      fetchGrades();
    } else {
      throw Exception('Failed to delete grade');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade List'),
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
        onPressed: _showAddGradeDialog,
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
              labelText: 'Search Grade',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    final int totalItems = grades.length;
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
    final filteredGrades = grades.where((grade) {
      final gradeName = grade['name'].toString().toLowerCase();
      return gradeName.contains(searchQuery.toLowerCase());
    }).toList();

    final paginatedGrades = filteredGrades.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('S.No.')),
            DataColumn(label: Text('Grade Name')),
            DataColumn(label: Text('From Range')),
            DataColumn(label: Text('To Range')),
            DataColumn(label: Text('Point')),
            DataColumn(label: Text('Category Name')),
            DataColumn(label: Text('Order No')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(
            paginatedGrades.length,
                (index) {
              final grade = paginatedGrades[index];
              return DataRow(
                cells: [
                  DataCell(Text('${(currentPage - 1) * itemsPerPage + index + 1}')),
                  DataCell(Text(grade['name'])),
                  DataCell(Text(grade['from_range'].toString())),
                  DataCell(Text(grade['to_range'].toString())),
                  DataCell(Text(grade['point'].toString())),
                  DataCell(Text(grade['category_name'])),
                  DataCell(Text(grade['order_no'].toString())),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditGradeDialog(grade);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteGrade(grade['id']);
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

  void _showEditGradeDialog(Map<String, dynamic> grade) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditGradeDialog(
          categories: categories,
          grade: grade,
          onSave: (updatedGrade) {
            editGrade(grade['id'], updatedGrade);
          },
        );
      },
    );
  }
}

class AddEditGradeDialog extends StatefulWidget {
  final List categories;
  final Map<String, dynamic>? grade;
  final Function(Map<String, dynamic>) onSave;

  AddEditGradeDialog({required this.categories, this.grade, required this.onSave});

  @override
  _AddEditGradeDialogState createState() => _AddEditGradeDialogState();
}

class _AddEditGradeDialogState extends State<AddEditGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _fromRange;
  String? _toRange;
  String? _point;
  String? _categoryId;
  String? _orderNo;
  String? _colorCode;
  String? _backColorCode;
  String? _displayMessage;

  @override
  void initState() {
    super.initState();
    if (widget.grade != null) {
      _name = widget.grade!['name'];
      _fromRange = widget.grade!['from_range'].toString();
      _toRange = widget.grade!['to_range'].toString();
      _point = widget.grade!['point'].toString();
      _categoryId = widget.grade!['category_id'].toString();
      _orderNo = widget.grade!['order_no'].toString();
      _colorCode = widget.grade!['color_code'];
      _backColorCode = widget.grade!['back_color_code'];
      _displayMessage = widget.grade!['display_message'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.grade != null ? 'Edit Grade' : 'Add New Grade'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                value: _categoryId,
                items: widget.categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _categoryId = value as String?;
                  });
                },
              ),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Grade Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a grade name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              TextFormField(
                initialValue: _fromRange,
                decoration: InputDecoration(labelText: 'From Range'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a from range';
                  }
                  return null;
                },
                onSaved: (value) {
                  _fromRange = value;
                },
              ),
              TextFormField(
                initialValue: _toRange,
                decoration: InputDecoration(labelText: 'To Range'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a to range';
                  }
                  return null;
                },
                onSaved: (value) {
                  _toRange = value;
                },
              ),
              TextFormField(
                initialValue: _point,
                decoration: InputDecoration(labelText: 'Point'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a point';
                  }
                  return null;
                },
                onSaved: (value) {
                  _point = value;
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
              TextFormField(
                initialValue: _colorCode,
                decoration: InputDecoration(labelText: 'Color Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a color code';
                  }
                  return null;
                },
                onSaved: (value) {
                  _colorCode = value;
                },
              ),
              TextFormField(
                initialValue: _backColorCode,
                decoration: InputDecoration(labelText: 'Back Color Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a back color code';
                  }
                  return null;
                },
                onSaved: (value) {
                  _backColorCode = value;
                },
              ),
              TextFormField(
                initialValue: _displayMessage,
                decoration: InputDecoration(labelText: 'Display Message'),
                onSaved: (value) {
                  _displayMessage = value;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave({
                'name': _name,
                'from_range': _fromRange,
                'to_range': _toRange,
                'point': _point,
                'category_id': _categoryId,
                'order_no': _orderNo,
                'color_code': _colorCode,
                'back_color_code': _backColorCode,
                'display_message': _displayMessage,
              });
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.grade != null ? 'Save' : 'Add'),
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
