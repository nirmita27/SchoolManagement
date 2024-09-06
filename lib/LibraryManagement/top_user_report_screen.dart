import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TopUserReportScreen extends StatefulWidget {
  @override
  _TopUserReportScreenState createState() => _TopUserReportScreenState();
}

class _TopUserReportScreenState extends State<TopUserReportScreen> {
  List topUsers = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTopUsers();
  }

  Future<void> _fetchTopUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/top_user_report?search=$searchQuery'));
      if (response.statusCode == 200) {
        setState(() {
          topUsers = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load top user report');
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
    _fetchTopUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top User Report'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Report',
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
                : topUsers.isEmpty
                ? Center(child: Text('No Records Found.'))
                : ListView.builder(
              itemCount: topUsers.length,
              itemBuilder: (context, index) {
                final user = topUsers[index];
                return Card(
                  child: ListTile(
                    title: Text(user['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admission No: ${user['student_id']}'),
                        Text('Gender: ${user['gender']}'),
                        Text('Class & Section: ${user['class_section']}'),
                        Text('EmailID: ${user['email']}'),
                        Text('Mobile No: ${user['phone_number']}'),
                        Text('Total Issued Books: ${user['total_issued_books']}'),
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
