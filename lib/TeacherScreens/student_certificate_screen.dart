import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentCertificateScreen extends StatefulWidget {
  @override
  _StudentCertificateScreenState createState() => _StudentCertificateScreenState();
}

class _StudentCertificateScreenState extends State<StudentCertificateScreen> {
  List<dynamic> students = [];
  List<dynamic> certificates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _fetchCertificates();
  }

  Future<void> _fetchStudents() async {
    final url = Uri.parse('http://localhost:3000/student-details');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          students = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch students. Please try again.');
    }
  }

  Future<void> _fetchCertificates() async {
    final url = Uri.parse('http://localhost:3000/certificates');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          certificates = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load certificates');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch certificates. Please try again.');
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

  void _showCreateCertificateDialog() {
    final _studentIdController = TextEditingController();
    final _certificateTypeController = TextEditingController();
    final _issueDateController = TextEditingController();
    final _statusController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              items: students.map<DropdownMenuItem<String>>((student) {
                return DropdownMenuItem<String>(
                  value: student['serial_no'].toString(),
                  child: Text(student['student_name']),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Select Student'),
              onChanged: (value) {
                _studentIdController.text = value.toString();
              },
            ),
            TextField(
              controller: _certificateTypeController,
              decoration: InputDecoration(labelText: 'Certificate Type'),
            ),
            TextField(
              controller: _issueDateController,
              decoration: InputDecoration(labelText: 'Issue Date'),
            ),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text('Create'),
            onPressed: () {
              final studentId = _studentIdController.text;
              final certificateType = _certificateTypeController.text;
              final issueDate = _issueDateController.text;
              final status = _statusController.text;

              if (studentId.isNotEmpty && certificateType.isNotEmpty && issueDate.isNotEmpty && status.isNotEmpty) {
                _createCertificate(studentId, certificateType, issueDate, status);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _createCertificate(String studentId, String certificateType, String issueDate, String status) async {
    final url = Uri.parse('http://localhost:3000/certificates');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'certificate_type': certificateType,
          'issue_date': issueDate,
          'status': status,
        }),
      );
      if (response.statusCode == 201) {
        _fetchCertificates();
      } else {
        throw Exception('Failed to create certificate');
      }
    } catch (error) {
      _showErrorDialog('Failed to create certificate. Please try again.');
    }
  }

  void _showEditCertificateDialog(int certificateId, String certificateType, String issueDate, String status) {
    final _certificateTypeController = TextEditingController(text: certificateType);
    final _issueDateController = TextEditingController(text: issueDate);
    final _statusController = TextEditingController(text: status);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _certificateTypeController,
              decoration: InputDecoration(labelText: 'Certificate Type'),
            ),
            TextField(
              controller: _issueDateController,
              decoration: InputDecoration(labelText: 'Issue Date'),
            ),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text('Update'),
            onPressed: () {
              final newCertificateType = _certificateTypeController.text;
              final newIssueDate = _issueDateController.text;
              final newStatus = _statusController.text;

              if (newCertificateType.isNotEmpty && newIssueDate.isNotEmpty && newStatus.isNotEmpty) {
                _updateCertificate(certificateId, newCertificateType, newIssueDate, newStatus);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateCertificate(int certificateId, String certificateType, String issueDate, String status) async {
    final url = Uri.parse('http://localhost:3000/certificates/$certificateId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'certificate_type': certificateType,
          'issue_date': issueDate,
          'status': status,
        }),
      );
      if (response.statusCode == 200) {
        _fetchCertificates();
      } else {
        throw Exception('Failed to update certificate');
      }
    } catch (error) {
      _showErrorDialog('Failed to update certificate. Please try again.');
    }
  }

  void _showCertificateDetails(certificate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Certificate Details'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildCertificate(certificate),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(certificate) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(certificate['student_name'] ?? 'No Name'),
        subtitle: Text('Certificate Type: ${certificate['certificate_type'] ?? 'No Type'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _showEditCertificateDialog(
                  certificate['certificate_id'],
                  certificate['certificate_type'],
                  certificate['issue_date'],
                  certificate['status'],
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.visibility),
              onPressed: () {
                _showCertificateDetails(certificate);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificate(certificate) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Text(
            'CERTIFICATE OF ACHIEVEMENT',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'This certificate is proudly awarded to',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            certificate['student_name'] ?? 'No Name',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'in appreciation of their invaluable services and contributions to',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            certificate['certificate_type'] ?? 'No Type',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
          SizedBox(height: 20),
          Text(
            'Your dedication, hard work, and generosity have made a significant impact, and we are grateful for your support.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Issue Date: ${certificate['issue_date'] ?? 'No Date'}'),
              Text('Status: ${certificate['status'] ?? 'No Status'}'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Certificates'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateCertificateDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: certificates.length,
        itemBuilder: (ctx, index) {
          final certificate = certificates[index];
          return _buildCertificateCard(certificate);
        },
      ),
    );
  }
}
