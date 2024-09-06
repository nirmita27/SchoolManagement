import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApprovalPage extends StatefulWidget {
  @override
  _ApprovalPageState createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  List<dynamic> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> _fetchPendingRequests() async {
    final response = await http.get(Uri.parse('http://localhost:3000/pendingRequests'));
    if (response.statusCode == 200) {
      setState(() {
        _pendingRequests = json.decode(response.body);
      });
    }
  }

  Future<void> _updateRequestStatus(int userId, String status) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/updateStatus'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'userId': userId, 'status': status}),
    );
    if (response.statusCode == 200) {
      _fetchPendingRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request $status successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approval Requests'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: _pendingRequests.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 80, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text(
                'No pending approval requests.',
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
              SizedBox(height: 10),
              Text(
                'You have no tasks to approve at the moment. Enjoy your day!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _pendingRequests.length,
        itemBuilder: (context, index) {
          final request = _pendingRequests[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Text(
                  request['username'][0].toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                request['username'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(request['role']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () => _updateRequestStatus(request['id'], 'approved'),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => _updateRequestStatus(request['id'], 'rejected'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
