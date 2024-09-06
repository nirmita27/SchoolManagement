import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StaffConsolidationReportScreen extends StatefulWidget {
  @override
  _StaffConsolidationReportScreenState createState() => _StaffConsolidationReportScreenState();
}

class _StaffConsolidationReportScreenState extends State<StaffConsolidationReportScreen> {
  List staffConsolidationReport = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStaffConsolidationReport();
  }

  Future<void> _fetchStaffConsolidationReport() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/staff_consolidation_report?search=$searchQuery'));
      if (response.statusCode == 200) {
        setState(() {
          staffConsolidationReport = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load staff consolidation report');
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
    _fetchStaffConsolidationReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Consolidation Report'),
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
                : staffConsolidationReport.isEmpty
                ? Center(child: Text('No Records Found.'))
                : ListView.builder(
              itemCount: staffConsolidationReport.length,
              itemBuilder: (context, index) {
                final report = staffConsolidationReport[index];
                return Card(
                  child: ListTile(
                    title: Text(report['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Staff Number: ${report['staff_id']}'),
                        Text('Email: ${report['email']}'),
                        Text('Phone Number: ${report['phone_number']}'),
                        Text('Address: ${report['address']}'),
                        Text('DOB: ${report['dob']}'),
                        Text('Gender: ${report['gender']}'),
                        Text('Position: ${report['position']}'),
                        Text('Total Books: ${report['total_books']}'),
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
