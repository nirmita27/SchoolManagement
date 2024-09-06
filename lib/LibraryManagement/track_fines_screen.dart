import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackFinesScreen extends StatefulWidget {
  @override
  _TrackFinesScreenState createState() => _TrackFinesScreenState();
}

class _TrackFinesScreenState extends State<TrackFinesScreen> {
  List fines = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFines();
  }

  Future<void> _fetchFines() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/library_fines?search=$searchQuery'));
      if (response.statusCode == 200) {
        setState(() {
          fines = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load fines');
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
    _fetchFines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking Library Fines'),
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
                : fines.isEmpty
                ? Center(child: Text('No Records Found.'))
                : ListView.builder(
              itemCount: fines.length,
              itemBuilder: (context, index) {
                final fine = fines[index];
                return Card(
                  child: ListTile(
                    title: Text(fine['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Book Issued To: ${fine['student_id']}'),
                        Text('Name of Book: ${fine['book_name']}'),
                        Text('Fine Due: ${fine['fine']}'),
                        Text('Pay Mode: ${fine['paid'] ? 'Paid' : 'Unpaid'}'),
                        Text('Deposit Date: ${fine['deposit_date']}'),
                        Text('Remarks: ${fine['remarks']}'),
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
