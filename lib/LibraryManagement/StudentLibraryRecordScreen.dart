import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentLibraryRecordScreen extends StatefulWidget {
  @override
  _StudentLibraryRecordScreenState createState() => _StudentLibraryRecordScreenState();
}

class _StudentLibraryRecordScreenState extends State<StudentLibraryRecordScreen> {
  List records = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/student_library_records?search=$searchQuery'));
      if (response.statusCode == 200) {
        setState(() {
          records = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load records');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Library Record'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Student/Staff',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  child: ListTile(
                    title: Text(record['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Book Issued: ${record['book_name']}'),
                        Text('Issue Date: ${record['issue_date']}'),
                        Text('Due Date: ${record['receive_date']}'),
                        Text('Any Fines: ${record['fines']}'),
                        Text('Fine Paid: ${record['fine_paid']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
