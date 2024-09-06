import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'transportrequestform.dart';

class RequestDashboard extends StatefulWidget {
  @override
  _RequestDashboardState createState() => _RequestDashboardState();
}

class _RequestDashboardState extends State<RequestDashboard> {
  List<Map<String, dynamic>> requests = [];

  Future<void> fetchRequests() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/dashboard'), // Update with your actual backend URL
    );

    if (response.statusCode == 200) {
      setState(() {
        requests = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch requests.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransportRequestForm()),
              );
            },
          ),
        ],
      ),
      body: requests.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          border: TableBorder.all(color: Colors.blueAccent, width: 2),
          columns: [
            DataColumn(label: Text('Request Type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Pickup Address', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Drop Address', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: requests.map((request) {
            return DataRow(cells: [
              DataCell(Text(request['request_type'])),
              DataCell(Text(request['start_date'])),
              DataCell(Text(request['pickup_address'])),
              DataCell(Text(request['drop_address'])),
              DataCell(Text(request['remarks'])),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}