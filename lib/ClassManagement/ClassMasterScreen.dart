import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClassMasterScreen extends StatefulWidget {
  @override
  _ClassMasterScreenState createState() => _ClassMasterScreenState();
}

class _ClassMasterScreenState extends State<ClassMasterScreen> {
  List<dynamic> classes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    final url = Uri.parse('http://localhost:3000/classes');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          classes = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch classes. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? classData}) {
    final _classNameController = TextEditingController(text: classData?['class_name'] ?? '');
    final _classInWordsController = TextEditingController(text: classData?['class_in_words'] ?? '');
    final _promotedClassController = TextEditingController(text: classData?['promoted_class'] ?? '');
    final _promotedClassInWordsController = TextEditingController(text: classData?['promoted_class_in_words'] ?? '');
    final _orderNoController = TextEditingController(text: classData?['order_no']?.toString() ?? '');
    final _sessionController = TextEditingController(text: classData?['session'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(classData == null ? 'Add New Class' : 'Edit Class'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _classNameController,
                decoration: InputDecoration(labelText: 'Class Name'),
              ),
              TextField(
                controller: _classInWordsController,
                decoration: InputDecoration(labelText: 'Class In Words'),
              ),
              TextField(
                controller: _promotedClassController,
                decoration: InputDecoration(labelText: 'Promoted Class'),
              ),
              TextField(
                controller: _promotedClassInWordsController,
                decoration: InputDecoration(labelText: 'Promoted Class In Words'),
              ),
              TextField(
                controller: _orderNoController,
                decoration: InputDecoration(labelText: 'Order No'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _sessionController,
                decoration: InputDecoration(labelText: 'Session'),
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
            child: Text(classData == null ? 'Add' : 'Save'),
            onPressed: () {
              final className = _classNameController.text;
              final classInWords = _classInWordsController.text;
              final promotedClass = _promotedClassController.text;
              final promotedClassInWords = _promotedClassInWordsController.text;
              final orderNo = int.parse(_orderNoController.text);
              final session = _sessionController.text;

              if (classData == null) {
                _createClass(className, classInWords, promotedClass, promotedClassInWords, orderNo, session);
              } else {
                _editClass(classData['id'], className, classInWords, promotedClass, promotedClassInWords, orderNo, session);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createClass(String className, String classInWords, String promotedClass, String promotedClassInWords, int orderNo, String session) async {
    final url = Uri.parse('http://localhost:3000/classes');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'class_name': className,
          'class_in_words': classInWords,
          'promoted_class': promotedClass,
          'promoted_class_in_words': promotedClassInWords,
          'order_no': orderNo,
          'session': session,
        }),
      );
      if (response.statusCode == 201) {
        _fetchClasses();
      } else {
        throw Exception('Failed to create class');
      }
    } catch (error) {
      _showErrorDialog('Failed to create class. Please try again.');
    }
  }

  void _editClass(int id, String className, String classInWords, String promotedClass, String promotedClassInWords, int orderNo, String session) async {
    final url = Uri.parse('http://localhost:3000/classes/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'class_name': className,
          'class_in_words': classInWords,
          'promoted_class': promotedClass,
          'promoted_class_in_words': promotedClassInWords,
          'order_no': orderNo,
          'session': session,
        }),
      );
      if (response.statusCode == 200) {
        _fetchClasses();
      } else {
        throw Exception('Failed to edit class');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit class. Please try again.');
    }
  }

  void _deleteClass(int id) async {
    final url = Uri.parse('http://localhost:3000/classes/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchClasses();
      } else {
        throw Exception('Failed to delete class');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete class. Please try again.');
    }
  }

  Widget _buildClassTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Class Name')),
        DataColumn(label: Text('Class In Words')),
        DataColumn(label: Text('Promoted Class')),
        DataColumn(label: Text('Promoted Class In Words')),
        DataColumn(label: Text('Order No')),
        DataColumn(label: Text('Session')),
        DataColumn(label: Text('Actions')),
      ],
      rows: classes
          .asMap()
          .map((index, classData) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(classData['class_name'])),
          DataCell(Text(classData['class_in_words'] ?? 'N/A')),
          DataCell(Text(classData['promoted_class'] ?? 'N/A')),
          DataCell(Text(classData['promoted_class_in_words'] ?? 'N/A')),
          DataCell(Text(classData['order_no'].toString())),
          DataCell(Text(classData['session'] ?? 'N/A')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(classData: classData);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteClass(classData['id']);
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
        title: Text('Class Master'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: () {
              _showCreateEditDialog();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildClassTable(),
        ),
      ),
    );
  }
}
