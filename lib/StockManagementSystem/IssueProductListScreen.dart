import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IssueProductListScreen extends StatefulWidget {
  @override
  _IssueProductListScreenState createState() => _IssueProductListScreenState();
}

class _IssueProductListScreenState extends State<IssueProductListScreen> {
  List<dynamic> issues = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIssues();
  }

  Future<void> _fetchIssues() async {
    final url = Uri.parse('http://localhost:3000/issue-products');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          issues = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load issues');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch issues. Please try again.');
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

  void _showCreateIssueDialog() {
    final _dateController = TextEditingController();
    final _approverController = TextEditingController();
    final _issueToController = TextEditingController();
    final _productController = TextEditingController();
    final _quantityController = TextEditingController();
    final _unitController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _approvedByController = TextEditingController();
    final _postedByController = TextEditingController();
    final _postedOnController = TextEditingController();
    final _remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Issue Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: _approverController,
                decoration: InputDecoration(labelText: 'Approver'),
              ),
              TextField(
                controller: _issueToController,
                decoration: InputDecoration(labelText: 'Issue To'),
              ),
              TextField(
                controller: _productController,
                decoration: InputDecoration(labelText: 'Product'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _unitController,
                decoration: InputDecoration(labelText: 'Unit'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _approvedByController,
                decoration: InputDecoration(labelText: 'Approved By'),
              ),
              TextField(
                controller: _postedByController,
                decoration: InputDecoration(labelText: 'Posted By'),
              ),
              TextField(
                controller: _postedOnController,
                decoration: InputDecoration(labelText: 'Posted On'),
              ),
              TextField(
                controller: _remarksController,
                decoration: InputDecoration(labelText: 'Remarks'),
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
            child: Text('Add'),
            onPressed: () {
              final date = _dateController.text;
              final approver = _approverController.text;
              final issueTo = _issueToController.text;
              final product = _productController.text;
              final quantity = _quantityController.text;
              final unit = _unitController.text;
              final description = _descriptionController.text;
              final approvedBy = _approvedByController.text;
              final postedBy = _postedByController.text;
              final postedOn = _postedOnController.text;
              final remarks = _remarksController.text;

              if (date.isNotEmpty &&
                  approver.isNotEmpty &&
                  issueTo.isNotEmpty &&
                  product.isNotEmpty &&
                  quantity.isNotEmpty &&
                  unit.isNotEmpty &&
                  description.isNotEmpty &&
                  approvedBy.isNotEmpty &&
                  postedBy.isNotEmpty &&
                  postedOn.isNotEmpty &&
                  remarks.isNotEmpty) {
                _createIssue(date, approver, issueTo, product, int.parse(quantity), unit, description, approvedBy, postedBy, postedOn, remarks);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _createIssue(String date, String approver, String issueTo, String product, int quantity, String unit, String description, String approvedBy, String postedBy, String postedOn, String remarks) async {
    final url = Uri.parse('http://localhost:3000/issue-products');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date,
          'approver': approver,
          'issue_to': issueTo,
          'product': product,
          'quantity': quantity,
          'unit': unit,
          'description': description,
          'approved_by': approvedBy,
          'posted_by': postedBy,
          'posted_on': postedOn,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 201) {
        _fetchIssues();
      } else {
        throw Exception('Failed to create issue');
      }
    } catch (error) {
      _showErrorDialog('Failed to create issue. Please try again.');
    }
  }

  void _showEditIssueDialog(issue) {
    final _dateController = TextEditingController(text: issue['date']);
    final _approverController = TextEditingController(text: issue['approver']);
    final _issueToController = TextEditingController(text: issue['issue_to']);
    final _productController = TextEditingController(text: issue['product']);
    final _quantityController = TextEditingController(text: issue['quantity'].toString());
    final _unitController = TextEditingController(text: issue['unit']);
    final _descriptionController = TextEditingController(text: issue['description']);
    final _approvedByController = TextEditingController(text: issue['approved_by']);
    final _postedByController = TextEditingController(text: issue['posted_by']);
    final _postedOnController = TextEditingController(text: issue['posted_on']);
    final _remarksController = TextEditingController(text: issue['remarks']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Issue Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: _approverController,
                decoration: InputDecoration(labelText: 'Approver'),
              ),
              TextField(
                controller: _issueToController,
                decoration: InputDecoration(labelText: 'Issue To'),
              ),
              TextField(
                controller: _productController,
                decoration: InputDecoration(labelText: 'Product'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _unitController,
                decoration: InputDecoration(labelText: 'Unit'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _approvedByController,
                decoration: InputDecoration(labelText: 'Approved By'),
              ),
              TextField(
                controller: _postedByController,
                decoration: InputDecoration(labelText: 'Posted By'),
              ),
              TextField(
                controller: _postedOnController,
                decoration: InputDecoration(labelText: 'Posted On'),
              ),
              TextField(
                controller: _remarksController,
                decoration: InputDecoration(labelText: 'Remarks'),
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
            child: Text('Save'),
            onPressed: () {
              final date = _dateController.text;
              final approver = _approverController.text;
              final issueTo = _issueToController.text;
              final product = _productController.text;
              final quantity = _quantityController.text;
              final unit = _unitController.text;
              final description = _descriptionController.text;
              final approvedBy = _approvedByController.text;
              final postedBy = _postedByController.text;
              final postedOn = _postedOnController.text;
              final remarks = _remarksController.text;

              if (date.isNotEmpty &&
                  approver.isNotEmpty &&
                  issueTo.isNotEmpty &&
                  product.isNotEmpty &&
                  quantity.isNotEmpty &&
                  unit.isNotEmpty &&
                  description.isNotEmpty &&
                  approvedBy.isNotEmpty &&
                  postedBy.isNotEmpty &&
                  postedOn.isNotEmpty &&
                  remarks.isNotEmpty) {
                _updateIssue(issue['issue_id'], date, approver, issueTo, product, int.parse(quantity), unit, description, approvedBy, postedBy, postedOn, remarks);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateIssue(int id, String date, String approver, String issueTo, String product, int quantity, String unit, String description, String approvedBy, String postedBy, String postedOn, String remarks) async {
    final url = Uri.parse('http://localhost:3000/issue-products/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date,
          'approver': approver,
          'issue_to': issueTo,
          'product': product,
          'quantity': quantity,
          'unit': unit,
          'description': description,
          'approved_by': approvedBy,
          'posted_by': postedBy,
          'posted_on': postedOn,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 200) {
        _fetchIssues();
      } else {
        throw Exception('Failed to update issue');
      }
    } catch (error) {
      _showErrorDialog('Failed to update issue. Please try again.');
    }
  }

  void _deleteIssue(int id) async {
    final url = Uri.parse('http://localhost:3000/issue-products/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchIssues();
      } else {
        throw Exception('Failed to delete issue');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete issue. Please try again.');
    }
  }

  Widget _buildIssueDataTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Issue To')),
        DataColumn(label: Text('Approved By')),
        DataColumn(label: Text('Items')),
        DataColumn(label: Text('Actions')),
      ],
      rows: issues
          .asMap()
          .map((index, issue) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(issue['date'])),
          DataCell(Text(issue['issue_to'])),
          DataCell(Text(issue['approved_by'] ?? 'N/A')),
          DataCell(Text(issue['product'])),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditIssueDialog(issue);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteIssue(issue['issue_id']);
                  },
                ),
              ],
            ),
          ),
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
        title: Text('Issue Product List'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: _showCreateIssueDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildIssueDataTable(),
        ),
      ),
    );
  }
}
