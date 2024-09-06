import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApproveStudentLeaveScreen extends StatefulWidget {
  @override
  _ApproveStudentLeaveScreenState createState() => _ApproveStudentLeaveScreenState();
}

class _ApproveStudentLeaveScreenState extends State<ApproveStudentLeaveScreen> {
  List<dynamic> leaveList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaveList();
  }

  Future<void> _fetchLeaveList() async {
    final url = Uri.parse('http://localhost:3000/approve-student-leave');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          leaveList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load leave list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch leave list. Please try again.');
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

  Widget _buildLeaveListTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Applied By')),
        DataColumn(label: Text('Class')),
        DataColumn(label: Text('Applied On')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Remarks')),
      ],
      rows: leaveList
          .asMap()
          .map((index, leave) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(leave['applied_by'] ?? '')),
          DataCell(Text(leave['class'] ?? '')),
          DataCell(Text(leave['applied_on'] ?? '')),
          DataCell(Text(leave['date'] ?? '')),
          DataCell(Text(leave['type'] ?? '')),
          DataCell(Text(leave['remarks'] ?? '')),
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
        title: Text('Approve Student Leave List'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildLeaveListTable(),
        ),
      ),
    );
  }
}
