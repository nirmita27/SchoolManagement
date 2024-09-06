import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubjectMasterScreen extends StatefulWidget {
  @override
  _SubjectMasterScreenState createState() => _SubjectMasterScreenState();
}

class _SubjectMasterScreenState extends State<SubjectMasterScreen> {
  List<dynamic> subjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    final url = Uri.parse('http://localhost:3000/subjects');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          subjects = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load subjects');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch subjects. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? subject}) {
    final _subjectNameController = TextEditingController(text: subject?['subject_name']);
    final _subjectShortNameController = TextEditingController(text: subject?['subject_short_name']);
    final _orderNoController = TextEditingController(text: subject?['order_no']?.toString());
    final _colorCodeController = TextEditingController(text: subject?['color_code']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(subject == null ? 'Add Subject' : 'Edit Subject'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _subjectNameController,
                decoration: InputDecoration(labelText: 'Subject Name'),
              ),
              TextField(
                controller: _subjectShortNameController,
                decoration: InputDecoration(labelText: 'Subject Short Name'),
              ),
              TextField(
                controller: _orderNoController,
                decoration: InputDecoration(labelText: 'Order No'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _colorCodeController,
                decoration: InputDecoration(labelText: 'Color Code for Graph'),
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
            child: Text(subject == null ? 'Add' : 'Save'),
            onPressed: () {
              final subjectName = _subjectNameController.text;
              final subjectShortName = _subjectShortNameController.text;
              final orderNo = _orderNoController.text;
              final colorCode = _colorCodeController.text;

              if (subjectName.isNotEmpty &&
                  subjectShortName.isNotEmpty &&
                  orderNo.isNotEmpty &&
                  colorCode.isNotEmpty) {
                if (subject == null) {
                  _createSubject(subjectName, subjectShortName, int.parse(orderNo), colorCode);
                } else {
                  _editSubject(subject['id'], subjectName, subjectShortName, int.parse(orderNo), colorCode);
                }
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

  void _createSubject(String subjectName, String subjectShortName, int orderNo, String colorCode) async {
    final url = Uri.parse('http://localhost:3000/subjects');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'subject_name': subjectName,
          'subject_short_name': subjectShortName,
          'order_no': orderNo,
          'color_code': colorCode,
        }),
      );
      if (response.statusCode == 201) {
        _fetchSubjects();
      } else {
        throw Exception('Failed to create subject');
      }
    } catch (error) {
      _showErrorDialog('Failed to create subject. Please try again.');
    }
  }

  void _editSubject(int id, String subjectName, String subjectShortName, int orderNo, String colorCode) async {
    final url = Uri.parse('http://localhost:3000/subjects/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'subject_name': subjectName,
          'subject_short_name': subjectShortName,
          'order_no': orderNo,
          'color_code': colorCode,
        }),
      );
      if (response.statusCode == 200) {
        _fetchSubjects();
      } else {
        throw Exception('Failed to edit subject');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit subject. Please try again.');
    }
  }

  void _deleteSubject(int id) async {
    final url = Uri.parse('http://localhost:3000/subjects/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchSubjects();
      } else {
        throw Exception('Failed to delete subject');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete subject. Please try again.');
    }
  }

  Widget _buildSubjectTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Subject Name')),
        DataColumn(label: Text('Order No.')),
        DataColumn(label: Text('Actions')),
      ],
      rows: subjects
          .asMap()
          .map((index, subject) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(subject['subject_name'])),
          DataCell(Text(subject['order_no'].toString())),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(subject: subject);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteSubject(subject['id']);
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
        title: Text('Subject Master'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildSubjectTable(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEditDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: SubjectMasterScreen(),
  ));
}
