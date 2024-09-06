import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TermMasterScreen extends StatefulWidget {
  @override
  _TermMasterScreenState createState() => _TermMasterScreenState();
}

class _TermMasterScreenState extends State<TermMasterScreen> {
  List terms = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchTerms();
  }

  Future<void> fetchTerms() async {
    final response = await http.get(Uri.parse('http://localhost:3000/terms'));
    if (response.statusCode == 200) {
      setState(() {
        terms = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load terms');
    }
  }

  void _showAddTermDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditTermDialog(
          onSave: (term) {
            addTerm(term);
          },
        );
      },
    );
  }

  Future<void> addTerm(Map<String, dynamic> term) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/terms'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(term),
    );
    if (response.statusCode == 201) {
      fetchTerms();
    } else {
      throw Exception('Failed to add term');
    }
  }

  Future<void> editTerm(int id, Map<String, dynamic> term) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/terms/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(term),
    );
    if (response.statusCode == 200) {
      fetchTerms();
    } else {
      throw Exception('Failed to edit term');
    }
  }

  Future<void> deleteTerm(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/terms/$id'),
    );
    if (response.statusCode == 200) {
      fetchTerms();
    } else {
      throw Exception('Failed to delete term');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Term Master'),
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
        onPressed: _showAddTermDialog,
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
              labelText: 'Search Term',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    final int totalItems = terms.length;
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
    final filteredTerms = terms
        .where((term) =>
    term['term_name']
        .toString()
        .toLowerCase()
        .contains(searchQuery.toLowerCase()) ||
        term['term_code']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    final int totalItems = filteredTerms.length;
    final int startItem = (currentPage - 1) * itemsPerPage;
    final int endItem = startItem + itemsPerPage;
    final List displayedTerms = filteredTerms.sublist(
      startItem,
      endItem > totalItems ? totalItems : endItem,
    );

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('S.No.')),
            DataColumn(label: Text('Term Name')),
            DataColumn(label: Text('Start Date')),
            DataColumn(label: Text('End Date')),
            DataColumn(label: Text('Term Code')),
            DataColumn(label: Text('Order No')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List<DataRow>.generate(
            displayedTerms.length,
                (index) {
              final term = displayedTerms[index];
              return DataRow(
                cells: [
                  DataCell(Text((startItem + index + 1).toString())),
                  DataCell(Text(term['term_name'])),
                  DataCell(Text(term['start_date'] ?? '')),
                  DataCell(Text(term['end_date'] ?? '')),
                  DataCell(Text(term['term_code'])),
                  DataCell(Text(term['order_no'].toString())),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditTermDialog(term['id'], term),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteTerm(term['id']),
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

  void _showEditTermDialog(int id, Map<String, dynamic> term) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditTermDialog(
          term: term,
          onSave: (updatedTerm) {
            editTerm(id, updatedTerm);
          },
        );
      },
    );
  }
}

class AddEditTermDialog extends StatefulWidget {
  final Map<String, dynamic>? term;
  final Function(Map<String, dynamic>) onSave;

  AddEditTermDialog({this.term, required this.onSave});

  @override
  _AddEditTermDialogState createState() => _AddEditTermDialogState();
}

class _AddEditTermDialogState extends State<AddEditTermDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _termName;
  late String _termCode;
  late int _orderNo;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.term != null) {
      _termName = widget.term!['term_name'];
      _termCode = widget.term!['term_code'];
      _orderNo = widget.term!['order_no'];
      _startDate = DateTime.tryParse(widget.term!['start_date'] ?? '');
      _endDate = DateTime.tryParse(widget.term!['end_date'] ?? '');
    } else {
      _termName = '';
      _termCode = '';
      _orderNo = 0;
      _startDate = null;
      _endDate = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.term != null ? 'Edit Term' : 'Add Term'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _termName,
              decoration: InputDecoration(labelText: 'Term Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a term name';
                }
                return null;
              },
              onSaved: (value) {
                _termName = value!;
              },
            ),
            TextFormField(
              initialValue: _termCode,
              decoration: InputDecoration(labelText: 'Term Code'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a term code';
                }
                return null;
              },
              onSaved: (value) {
                _termCode = value!;
              },
            ),
            TextFormField(
              initialValue: _orderNo.toString(),
              decoration: InputDecoration(labelText: 'Order No'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an order number';
                }
                return null;
              },
              onSaved: (value) {
                _orderNo = int.parse(value!);
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Start Date: ${_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : ''}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('End Date: ${_endDate != null ? _endDate!.toLocal().toString().split(' ')[0] : ''}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
                  ),
                ),
              ],
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
                'term_name': _termName,
                'start_date': _startDate?.toIso8601String(),
                'end_date': _endDate?.toIso8601String(),
                'term_code': _termCode,
                'order_no': _orderNo,
              });
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.term != null ? 'Save' : 'Add'),
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
