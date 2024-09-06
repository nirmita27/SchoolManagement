import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaveListScreen extends StatefulWidget {
  @override
  _LeaveListScreenState createState() => _LeaveListScreenState();
}

class _LeaveListScreenState extends State<LeaveListScreen> {
  List<dynamic> leaveList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaveList();
  }

  Future<void> _fetchLeaveList() async {
    final url = Uri.parse('http://localhost:3000/leave-list');
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
        DataColumn(label: Text('User Type')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Apply On')),
        DataColumn(label: Text('Leave Type')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Actions')),
      ],
      rows: leaveList
          .asMap()
          .map((index, leave) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(leave['user_type'] ?? '')),
          DataCell(Text(leave['name'] ?? '')),
          DataCell(Text(leave['apply_on'] ?? '')),
          DataCell(Text(leave['leave_type'] ?? '')),
          DataCell(Text(leave['date'] ?? '')),
          DataCell(Row(
            children: [
              TextButton(
                child: Text('View Balance', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  // Implement View Balance functionality
                },
              ),
              TextButton(
                child: Text('Apply A Leave', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  // Implement Apply A Leave functionality
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
        title: Text('Leave List'),
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
