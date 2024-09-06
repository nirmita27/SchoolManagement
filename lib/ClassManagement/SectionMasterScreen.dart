import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SectionMasterScreen extends StatefulWidget {
  @override
  _SectionMasterScreenState createState() => _SectionMasterScreenState();
}

class _SectionMasterScreenState extends State<SectionMasterScreen> {
  List<dynamic> sections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSections();
  }

  Future<void> _fetchSections() async {
    final url = Uri.parse('http://localhost:3000/sections');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          sections = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load sections');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch sections. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? section}) {
    final _sectionNameController = TextEditingController(text: section?['section_name'] ?? '');
    final _orderNoController = TextEditingController(text: section?['order_no']?.toString() ?? '');
    final _sessionController = TextEditingController(text: section?['session']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(section == null ? 'Add New Section' : 'Edit Section'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _sectionNameController,
                decoration: InputDecoration(labelText: 'Section Name'),
              ),
              TextField(
                controller: _orderNoController,
                decoration: InputDecoration(labelText: 'Order No'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _sessionController,
                decoration: InputDecoration(labelText: 'Session'),
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
            child: Text(section == null ? 'Add' : 'Save'),
            onPressed: () {
              final sectionName = _sectionNameController.text;
              final orderNo = int.parse(_orderNoController.text);
              final session = int.parse(_sessionController.text);

              if (section == null) {
                _addSection(sectionName, orderNo, session);
              } else {
                _editSection(section['id'], sectionName, orderNo, session);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _addSection(String sectionName, int orderNo, int session) async {
    final url = Uri.parse('http://localhost:3000/sections');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'section_name': sectionName,
          'order_no': orderNo,
          'session': session,
        }),
      );
      if (response.statusCode == 201) {
        _fetchSections();
      } else {
        throw Exception('Failed to add section');
      }
    } catch (error) {
      _showErrorDialog('Failed to add section. Please try again.');
    }
  }

  void _editSection(int id, String sectionName, int orderNo, int session) async {
    final url = Uri.parse('http://localhost:3000/sections/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'section_name': sectionName,
          'order_no': orderNo,
          'session': session,
        }),
      );
      if (response.statusCode == 200) {
        _fetchSections();
      } else {
        throw Exception('Failed to edit section');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit section. Please try again.');
    }
  }

  void _deleteSection(int id) async {
    final url = Uri.parse('http://localhost:3000/sections/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchSections();
      } else {
        throw Exception('Failed to delete section');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete section. Please try again.');
    }
  }

  Widget _buildSectionTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Section Name')),
        DataColumn(label: Text('Order No.')),
        DataColumn(label: Text('Session')),
        DataColumn(label: Text('Actions')),
      ],
      rows: sections
          .asMap()
          .map((index, section) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(section['section_name'] ?? 'N/A')),
          DataCell(Text(section['order_no']?.toString() ?? 'N/A')),
          DataCell(
            GestureDetector(
              onTap: () {
                _showSessionDialog(section['session']);
              },
              child: Text('${section['session'] ?? 'N/A'} Session'),
            ),
          ),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(section: section);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteSection(section['id']);
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

  void _showSessionDialog(int session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('VIEW SESSION'),
        content: Text('Session: $session'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Section Master'),
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
          child: _buildSectionTable(),
        ),
      ),
    );
  }
}
