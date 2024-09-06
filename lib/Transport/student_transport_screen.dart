import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentTransportScreen extends StatefulWidget {
  @override
  _StudentTransportScreenState createState() => _StudentTransportScreenState();
}

class _StudentTransportScreenState extends State<StudentTransportScreen> {
  List<Map<String, dynamic>> students = [];

  Future<void> fetchStudents() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/students'), // Update with your actual backend URL
    );

    if (response.statusCode == 200) {
      setState(() {
        students = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch student transport details.')),
      );
    }
  }

  Future<void> addStudent(Map<String, dynamic> student) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/students'), // Update with your actual backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode(student),
    );

    if (response.statusCode == 201) {
      fetchStudents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add student transport detail.')),
      );
    }
  }

  Future<void> updateStudent(int id, Map<String, dynamic> student) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/students/$id'), // Update with your actual backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode(student),
    );

    if (response.statusCode == 200) {
      fetchStudents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update student transport detail.')),
      );
    }
  }

  Future<void> deleteStudent(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/students/$id'), // Update with your actual backend URL
    );

    if (response.statusCode == 200) {
      fetchStudents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete student transport detail.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  void _showAddStudentForm() {
    final _serialNumberController = TextEditingController();
    final _studentNameController = TextEditingController();
    final _admissionNumberController = TextEditingController();
    final _classController = TextEditingController();
    final _mobileNumberController = TextEditingController();
    final _addressController = TextEditingController();
    final _routeController = TextEditingController();
    final _vehicleController = TextEditingController();
    final _busStopController = TextEditingController();
    String _transportFor = 'Pickup';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Student Transport Detail'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _serialNumberController,
                  decoration: InputDecoration(labelText: 'Serial Number'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _studentNameController,
                  decoration: InputDecoration(labelText: 'Student Name'),
                ),
                TextField(
                  controller: _admissionNumberController,
                  decoration: InputDecoration(labelText: 'Admission Number'),
                ),
                TextField(
                  controller: _classController,
                  decoration: InputDecoration(labelText: 'Class'),
                ),
                TextField(
                  controller: _mobileNumberController,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: _routeController,
                  decoration: InputDecoration(labelText: 'Route'),
                ),
                TextField(
                  controller: _vehicleController,
                  decoration: InputDecoration(labelText: 'Vehicle'),
                ),
                TextField(
                  controller: _busStopController,
                  decoration: InputDecoration(labelText: 'Bus Stop'),
                ),
                DropdownButtonFormField<String>(
                  value: _transportFor,
                  decoration: InputDecoration(labelText: 'Transport For'),
                  items: ['Pickup', 'Drop']
                      .map((label) => DropdownMenuItem(
                    child: Text(label),
                    value: label,
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _transportFor = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final student = {
                  'serial_number': _serialNumberController.text,
                  'student_name': _studentNameController.text,
                  'admission_number': _admissionNumberController.text,
                  'class': _classController.text,
                  'mobile_number': _mobileNumberController.text,
                  'address': _addressController.text,
                  'route': _routeController.text,
                  'vehicle': _vehicleController.text,
                  'bus_stop': _busStopController.text,
                  'transport_for': _transportFor,
                };
                addStudent(student);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditStudentForm(Map<String, dynamic> student) {
    final _serialNumberController = TextEditingController(text: student['serial_number'].toString());
    final _studentNameController = TextEditingController(text: student['student_name']);
    final _admissionNumberController = TextEditingController(text: student['admission_number']);
    final _classController = TextEditingController(text: student['class']);
    final _mobileNumberController = TextEditingController(text: student['mobile_number']);
    final _addressController = TextEditingController(text: student['address']);
    final _routeController = TextEditingController(text: student['route']);
    final _vehicleController = TextEditingController(text: student['vehicle']);
    final _busStopController = TextEditingController(text: student['bus_stop']);
    String _transportFor = student['transport_for'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Student Transport Detail'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _serialNumberController,
                  decoration: InputDecoration(labelText: 'Serial Number'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _studentNameController,
                  decoration: InputDecoration(labelText: 'Student Name'),
                ),
                TextField(
                  controller: _admissionNumberController,
                  decoration: InputDecoration(labelText: 'Admission Number'),
                ),
                TextField(
                  controller: _classController,
                  decoration: InputDecoration(labelText: 'Class'),
                ),
                TextField(
                  controller: _mobileNumberController,
                  decoration: InputDecoration(labelText: 'Mobile Number'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: _routeController,
                  decoration: InputDecoration(labelText: 'Route'),
                ),
                TextField(
                  controller: _vehicleController,
                  decoration: InputDecoration(labelText: 'Vehicle'),
                ),
                TextField(
                  controller: _busStopController,
                  decoration: InputDecoration(labelText: 'Bus Stop'),
                ),
                DropdownButtonFormField<String>(
                  value: _transportFor,
                  decoration: InputDecoration(labelText: 'Transport For'),
                  items: ['Pickup', 'Drop']
                      .map((label) => DropdownMenuItem(
                    child: Text(label),
                    value: label,
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _transportFor = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedStudent = {
                  'serial_number': _serialNumberController.text,
                  'student_name': _studentNameController.text,
                  'admission_number': _admissionNumberController.text,
                  'class': _classController.text,
                  'mobile_number': _mobileNumberController.text,
                  'address': _addressController.text,
                  'route': _routeController.text,
                  'vehicle': _vehicleController.text,
                  'bus_stop': _busStopController.text,
                  'transport_for': _transportFor,
                };
                updateStudent(student['id'], updatedStudent);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Transport Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddStudentForm,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 16, // Adjust spacing between columns
              horizontalMargin: 12, // Adjust horizontal margin
              columns: [
                DataColumn(label: Text('Serial Number', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Admission Number', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Class', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Mobile Number', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Route', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Vehicle', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Bus Stop', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Transport For', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: students.map((student) {
                return DataRow(cells: [
                  DataCell(Text(student['serial_number']?.toString() ?? '')),
                  DataCell(Text(student['student_name'] ?? '')),
                  DataCell(Text(student['admission_number'] ?? '')),
                  DataCell(Text(student['class'] ?? '')),
                  DataCell(Text(student['mobile_number'] ?? '')),
                  DataCell(Text(student['address'] ?? '')),
                  DataCell(Text(student['route'] ?? '')),
                  DataCell(Text(student['vehicle'] ?? '')),
                  DataCell(Text(student['bus_stop'] ?? '')),
                  DataCell(Text(student['transport_for'] ?? '')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditStudentForm(student),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteStudent(student['id']),
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
