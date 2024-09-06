import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SyllabusMasterScreen extends StatefulWidget {
  @override
  _SyllabusMasterScreenState createState() => _SyllabusMasterScreenState();
}

class _SyllabusMasterScreenState extends State<SyllabusMasterScreen> {
  List<dynamic> syllabi = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSyllabi();
  }

  Future<void> _fetchSyllabi() async {
    final url = Uri.parse('http://localhost:3000/syllabi');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          syllabi = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load syllabi');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch syllabi. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? syllabus}) {
    final _classController = TextEditingController(text: syllabus?['class']);
    final _subjectController = TextEditingController(text: syllabus?['subject']);
    final _topicsController = List.generate(
      5,
          (index) => TextEditingController(
          text: syllabus != null && syllabus['syllabus'].length > index
              ? syllabus['syllabus'][index]['topic']
              : ''),
    );
    final _startDateController = List.generate(
      5,
          (index) => TextEditingController(
          text: syllabus != null && syllabus['syllabus'].length > index
              ? syllabus['syllabus'][index]['start_date']
              : ''),
    );
    final _endDateController = List.generate(
      5,
          (index) => TextEditingController(
          text: syllabus != null && syllabus['syllabus'].length > index
              ? syllabus['syllabus'][index]['end_date']
              : ''),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(syllabus == null ? 'Add New Syllabus' : 'Edit Syllabus'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                items: ['Class 1', 'Class 2', 'Class 3']
                    .map<DropdownMenuItem<String>>((className) {
                  return DropdownMenuItem<String>(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Class'),
                onChanged: (value) {
                  _classController.text = value.toString();
                },
              ),
              DropdownButtonFormField(
                items: ['Subject 1', 'Subject 2', 'Subject 3']
                    .map<DropdownMenuItem<String>>((subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Subject'),
                onChanged: (value) {
                  _subjectController.text = value.toString();
                },
              ),
              ...List.generate(5, (index) {
                return Column(
                  children: [
                    TextField(
                      controller: _topicsController[index],
                      decoration: InputDecoration(
                          labelText: 'Please Enter Topic ${index + 1}...'),
                    ),
                    TextField(
                      controller: _startDateController[index],
                      decoration: InputDecoration(
                          labelText: 'Start Date (DD/MM/YYYY)'),
                    ),
                    TextField(
                      controller: _endDateController[index],
                      decoration: InputDecoration(
                          labelText: 'End Date (DD/MM/YYYY)'),
                    ),
                  ],
                );
              }),
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
            child: Text(syllabus == null ? 'Add' : 'Save'),
            onPressed: () {
              final className = _classController.text;
              final subject = _subjectController.text;
              final syllabusData = List.generate(
                5,
                    (index) => {
                  'topic': _topicsController[index].text,
                  'start_date': _startDateController[index].text,
                  'end_date': _endDateController[index].text,
                },
              );

              if (className.isNotEmpty && subject.isNotEmpty) {
                if (syllabus == null) {
                  _createSyllabus(className, subject, syllabusData);
                } else {
                  _editSyllabus(syllabus['id'], className, subject, syllabusData);
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

  void _createSyllabus(
      String className, String subject, List<Map<String, String>> syllabus) async {
    final url = Uri.parse('http://localhost:3000/syllabi');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'class': className,
          'subject': subject,
          'syllabus': syllabus,
        }),
      );
      if (response.statusCode == 201) {
        _fetchSyllabi();
      } else {
        throw Exception('Failed to create syllabus');
      }
    } catch (error) {
      _showErrorDialog('Failed to create syllabus. Please try again.');
    }
  }

  void _editSyllabus(
      int id, String className, String subject, List<Map<String, String>> syllabus) async {
    final url = Uri.parse('http://localhost:3000/syllabi/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'class': className,
          'subject': subject,
          'syllabus': syllabus,
        }),
      );
      if (response.statusCode == 200) {
        _fetchSyllabi();
      } else {
        throw Exception('Failed to edit syllabus');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit syllabus. Please try again.');
    }
  }

  void _deleteSyllabus(int id) async {
    final url = Uri.parse('http://localhost:3000/syllabi/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchSyllabi();
      } else {
        throw Exception('Failed to delete syllabus');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete syllabus. Please try again.');
    }
  }

  Widget _buildSyllabusTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Class')),
        DataColumn(label: Text('Subject Name')),
        DataColumn(label: Text('Syllabus')),
        DataColumn(label: Text('Actions')),
      ],
      rows: syllabi
          .asMap()
          .map((index, syllabus) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(syllabus['class'])),
          DataCell(Text(syllabus['subject'])),
          DataCell(Text(syllabus['syllabus'].map((e) => e['topic']).join(', '))),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(syllabus: syllabus);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteSyllabus(syllabus['id']);
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
        title: Text('Syllabus Master'),
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
          child: _buildSyllabusTable(),
        ),
      ),
    );
  }
}
