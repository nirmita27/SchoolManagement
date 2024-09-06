import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentHomeworkPage extends StatefulWidget {
  final String studentClass;

  StudentHomeworkPage({required this.studentClass});

  @override
  _StudentHomeworkPageState createState() => _StudentHomeworkPageState();
}

class _StudentHomeworkPageState extends State<StudentHomeworkPage> {
  List<dynamic> homeworkList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomework();
  }

  Future<void> _fetchHomework() async {
    final url = Uri.parse('http://localhost:3000/homework/${widget.studentClass}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Homework: $data'); // Debug statement
        setState(() {
          homeworkList = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load homework');
      }
    } catch (error) {
      print('Error fetching homework: $error'); // Debug statement
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch homework. Please try again.');
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homework'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchHomework,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: homeworkList.length,
          itemBuilder: (ctx, index) {
            final homework = homeworkList[index];
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Text(
                  homework['title'] ?? 'N/A',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  homework['description'] ?? 'N/A',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Due: ${homework['due_date']}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Status: ${homework['status']}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: homework['status'] == 'completed' ? Colors.green : Colors.orange),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
