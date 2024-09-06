import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:translator/translator.dart';

class StudentListScreen extends StatefulWidget {
  final String schoolRange;

  StudentListScreen({required this.schoolRange});

  @override
  _StudentListScreenState createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  bool _isHindi = false;
  int _offset = 0;
  final int _limit = 50;
  bool _hasMore = true;
  int _currentPage = 1;

  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/studentList?offset=$_offset&limit=$_limit&schoolRange=${widget.schoolRange}'));
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> students = List<Map<String, dynamic>>.from(json.decode(response.body));
        setState(() {
          _students = students;
          _isLoading = false;
          _hasMore = students.length == _limit;
        });
      } else {
        print('Failed to fetch students');
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  Future<void> _addStudent(Map<String, dynamic> student) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/addStudent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(student),
      );
      if (response.statusCode == 201) {
        setState(() {
          _students.insert(0, json.decode(response.body));
        });
      } else {
        print('Failed to add student');
      }
    } catch (e) {
      print('Error adding student: $e');
    }
  }

  Future<void> _updateStudent(int id, Map<String, dynamic> student) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/updateStudent/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(student),
      );
      if (response.statusCode == 200) {
        setState(() {
          int index = _students.indexWhere((s) => s['serial_no'] == id);
          if (index != -1) {
            _students[index] = json.decode(response.body);
          }
        });
      } else {
        print('Failed to update student');
      }
    } catch (e) {
      print('Error updating student: $e');
    }
  }

  Future<void> _deleteStudent(int id) async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:3000/deleteStudent/$id'));
      if (response.statusCode == 204) {
        setState(() {
          _students.removeWhere((s) => s['serial_no'] == id);
        });
      } else {
        print('Failed to delete student');
      }
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  Future<void> _showEditDialog({Map<String, dynamic>? student}) async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String studentName = student?['student_name'] ?? '';
    String fatherName = student?['father_name'] ?? '';
    String motherName = student?['mother_name'] ?? '';
    String address = student?['address'] ?? '';
    String mobileNumber = student?['mobile_number'] ?? '';
    String classSection = student?['class_section'] ?? '';

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(student == null ? 'Add Student' : 'Edit Student'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: studentName,
                    decoration: InputDecoration(labelText: 'Student Name'),
                    onSaved: (value) => studentName = value ?? '',
                  ),
                  TextFormField(
                    initialValue: fatherName,
                    decoration: InputDecoration(labelText: 'Father\'s Name'),
                    onSaved: (value) => fatherName = value ?? '',
                  ),
                  TextFormField(
                    initialValue: motherName,
                    decoration: InputDecoration(labelText: 'Mother\'s Name'),
                    onSaved: (value) => motherName = value ?? '',
                  ),
                  TextFormField(
                    initialValue: address,
                    decoration: InputDecoration(labelText: 'Address'),
                    onSaved: (value) => address = value ?? '',
                  ),
                  TextFormField(
                    initialValue: mobileNumber,
                    decoration: InputDecoration(labelText: 'Mobile Number'),
                    onSaved: (value) => mobileNumber = value ?? '',
                  ),
                  TextFormField(
                    initialValue: classSection,
                    decoration: InputDecoration(labelText: 'Class Section'),
                    onSaved: (value) => classSection = value ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(student == null ? 'Add' : 'Update'),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  if (student == null) {
                    _addStudent({
                      'student_name': studentName,
                      'father_name': fatherName,
                      'mother_name': motherName,
                      'address': address,
                      'mobile_number': mobileNumber,
                      'class_section': classSection,
                    });
                  } else {
                    _updateStudent(student['serial_no'], {
                      'student_name': studentName,
                      'father_name': fatherName,
                      'mother_name': motherName,
                      'address': address,
                      'mobile_number': mobileNumber,
                      'class_section': classSection,
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _translate(String text) async {
    if (_isHindi) {
      var translation = await translator.translate(text, from: 'en', to: 'hi');
      return translation.text;
    }
    return text;
  }

  Widget _buildStudentTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columns: [
            DataColumn(label: Text(_isHindi ? 'क्रम संख्या' : 'Serial No')),
            DataColumn(label: Text(_isHindi ? 'छात्र का नाम' : 'Student Name')),
            DataColumn(label: Text(_isHindi ? 'पिता का नाम' : 'Father\'s Name')),
            DataColumn(label: Text(_isHindi ? 'मां का नाम' : 'Mother\'s Name')),
            DataColumn(label: Text(_isHindi ? 'पता' : 'Address')),
            DataColumn(label: Text(_isHindi ? 'मोबाइल नंबर' : 'Mobile Number')),
            DataColumn(label: Text(_isHindi ? 'कक्षा अनुभाग' : 'Class Section')),
            DataColumn(label: Text(_isHindi ? 'कार्रवाई' : 'Actions')),
          ],
          rows: _students.map((student) {
            return DataRow(cells: [
              DataCell(Text(student['serial_no']?.toString() ?? 'N/A')),
              DataCell(FutureBuilder(
                future: _translate(student['student_name'] ?? 'N/A'),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? student['student_name'] ?? 'N/A');
                },
              )),
              DataCell(FutureBuilder(
                future: _translate(student['father_name'] ?? 'N/A'),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? student['father_name'] ?? 'N/A');
                },
              )),
              DataCell(FutureBuilder(
                future: _translate(student['mother_name'] ?? 'N/A'),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? student['mother_name'] ?? 'N/A');
                },
              )),
              DataCell(FutureBuilder(
                future: _translate(student['address'] ?? 'N/A'),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? student['address'] ?? 'N/A');
                },
              )),
              DataCell(FutureBuilder(
                future: _translate(student['mobile_number'] ?? 'N/A'),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? student['mobile_number'] ?? 'N/A');
                },
              )),
              DataCell(FutureBuilder(
                future: _translate(student['class_section'] ?? 'N/A'),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? student['class_section'] ?? 'N/A');
                },
              )),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _showEditDialog(student: student);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteStudent(student['serial_no']);
                      },
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _toggleLanguage() {
    setState(() {
      _isHindi = !_isHindi;
    });
  }

  void _goToNextPage() {
    if (_hasMore) {
      setState(() {
        _offset += _limit;
        _currentPage++;
        _isLoading = true;
      });
      _fetchStudents();
    }
  }

  void _goToPreviousPage() {
    if (_offset >= _limit) {
      setState(() {
        _offset -= _limit;
        _currentPage--;
        _isLoading = true;
      });
      _fetchStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isHindi ? 'छात्र सूची' : 'Student List'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _toggleLanguage,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_isLoading && _offset == 0)
                Center(child: CircularProgressIndicator())
              else ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildStudentTable(),
                ),
                if (!_isLoading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 1)
                        TextButton(
                          onPressed: _goToPreviousPage,
                          child: Text(_isHindi ? 'पिछला पृष्ठ' : 'Previous Page'),
                        ),
                      if (_hasMore)
                        TextButton(
                          onPressed: _goToNextPage,
                          child: Text(_isHindi ? 'अगला पृष्ठ' : 'Next Page'),
                        ),
                    ],
                  ),
                if (_isLoading && _offset > 0) Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEditDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
