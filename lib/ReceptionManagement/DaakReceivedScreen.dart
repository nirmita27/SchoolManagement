import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DaakReceivedScreen extends StatefulWidget {
  @override
  _DaakReceivedScreenState createState() => _DaakReceivedScreenState();
}

class _DaakReceivedScreenState extends State<DaakReceivedScreen> {
  List<dynamic> daakList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDaakList();
  }

  Future<void> _fetchDaakList() async {
    final url = Uri.parse('http://localhost:3000/daak-received');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          daakList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load daak list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch daak list. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? daak}) {
    final _receivedDateController = TextEditingController(text: daak?['received_date']);
    final _daakNumberController = TextEditingController(text: daak?['daak_number']);
    final _daakFromController = TextEditingController(text: daak?['daak_from']);
    final _receivedThroughController = TextEditingController(text: daak?['received_through']);
    final _deliveredAtController = TextEditingController(text: daak?['delivered_at']);
    final _contentController = TextEditingController(text: daak?['content']);
    final _receivedByController = TextEditingController(text: daak?['received_by']);
    final _remarkController = TextEditingController(text: daak?['remark']);
    final _assignToController = TextEditingController(text: daak?['assign_to']);
    final _reassignToController = TextEditingController(text: daak?['reassign_to']);
    final _reReassignToController = TextEditingController(text: daak?['re_reassign_to']);
    String? _attachment = daak?['attachment'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(daak == null ? 'Add New Daak' : 'Edit Daak'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _receivedDateController,
                decoration: InputDecoration(labelText: 'Received Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _receivedDateController.text = pickedDate.toString().split(' ')[0];
                  }
                },
              ),
              TextField(
                controller: _daakNumberController,
                decoration: InputDecoration(labelText: 'Number Daak'),
              ),
              TextField(
                controller: _daakFromController,
                decoration: InputDecoration(labelText: 'Daak From'),
              ),
              TextField(
                controller: _receivedThroughController,
                decoration: InputDecoration(labelText: 'Received Through'),
              ),
              TextField(
                controller: _deliveredAtController,
                decoration: InputDecoration(labelText: 'Delivered At'),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
              TextField(
                controller: _receivedByController,
                decoration: InputDecoration(labelText: 'Received By'),
              ),
              TextField(
                controller: _remarkController,
                decoration: InputDecoration(labelText: 'Remark'),
              ),
              TextField(
                controller: _assignToController,
                decoration: InputDecoration(labelText: 'Assign To'),
              ),
              TextField(
                controller: _reassignToController,
                decoration: InputDecoration(labelText: 'Reassign To'),
              ),
              TextField(
                controller: _reReassignToController,
                decoration: InputDecoration(labelText: 'Re-Reassign To'),
              ),
              SizedBox(height: 10),
              _attachment != null
                  ? TextButton(
                onPressed: () {
                  // Handle file download
                },
                child: Text('Download Attachment'),
              )
                  : Container(),
              TextButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                    allowMultiple: false,
                  );
                  if (result != null) {
                    File file = File(result.files.single.path!);
                    _attachment = file.path;
                  }
                },
                child: Text('Upload Attachment'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text(daak == null ? 'Add' : 'Save'),
            onPressed: () {
              final receivedDate = _receivedDateController.text;
              final daakNumber = _daakNumberController.text;
              final daakFrom = _daakFromController.text;
              final receivedThrough = _receivedThroughController.text;
              final deliveredAt = _deliveredAtController.text;
              final content = _contentController.text;
              final receivedBy = _receivedByController.text;
              final remark = _remarkController.text;
              final assignTo = _assignToController.text;
              final reassignTo = _reassignToController.text;
              final reReassignTo = _reReassignToController.text;

              if (daak == null) {
                _createDaak(receivedDate, daakNumber, daakFrom, receivedThrough, deliveredAt, content, receivedBy, remark, assignTo, reassignTo, reReassignTo, _attachment);
              } else {
                _editDaak(daak['id'], receivedDate, daakNumber, daakFrom, receivedThrough, deliveredAt, content, receivedBy, remark, assignTo, reassignTo, reReassignTo, _attachment);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createDaak(String receivedDate, String daakNumber, String daakFrom, String receivedThrough, String deliveredAt, String content, String receivedBy, String remark, String assignTo, String reassignTo, String reReassignTo, String? attachment) async {
    final url = Uri.parse('http://localhost:3000/daak-received');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['received_date'] = receivedDate;
      request.fields['daak_number'] = daakNumber;
      request.fields['daak_from'] = daakFrom;
      request.fields['received_through'] = receivedThrough;
      request.fields['delivered_at'] = deliveredAt;
      request.fields['content'] = content;
      request.fields['received_by'] = receivedBy;
      request.fields['remark'] = remark;
      request.fields['assign_to'] = assignTo;
      request.fields['reassign_to'] = reassignTo;
      request.fields['re_reassign_to'] = reReassignTo;

      if (attachment != null) {
        request.files.add(await http.MultipartFile.fromPath('attachment', attachment));
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        _fetchDaakList();
      } else {
        throw Exception('Failed to create daak');
      }
    } catch (error) {
      _showErrorDialog('Failed to create daak. Please try again.');
    }
  }

  void _editDaak(int id, String receivedDate, String daakNumber, String daakFrom, String receivedThrough, String deliveredAt, String content, String receivedBy, String remark, String assignTo, String reassignTo, String reReassignTo, String? attachment) async {
    final url = Uri.parse('http://localhost:3000/daak-received/$id');
    try {
      var request = http.MultipartRequest('PUT', url);
      request.fields['received_date'] = receivedDate;
      request.fields['daak_number'] = daakNumber;
      request.fields['daak_from'] = daakFrom;
      request.fields['received_through'] = receivedThrough;
      request.fields['delivered_at'] = deliveredAt;
      request.fields['content'] = content;
      request.fields['received_by'] = receivedBy;
      request.fields['remark'] = remark;
      request.fields['assign_to'] = assignTo;
      request.fields['reassign_to'] = reassignTo;
      request.fields['re_reassign_to'] = reReassignTo;

      if (attachment != null) {
        request.files.add(await http.MultipartFile.fromPath('attachment', attachment));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        _fetchDaakList();
      } else {
        throw Exception('Failed to edit daak');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit daak. Please try again.');
    }
  }

  void _deleteDaak(int id) async {
    final url = Uri.parse('http://localhost:3000/daak-received/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchDaakList();
      } else {
        throw Exception('Failed to delete daak');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete daak. Please try again.');
    }
  }

  Widget _buildDaakTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Received Date')),
        DataColumn(label: Text('Number Daak')),
        DataColumn(label: Text('Daak From')),
        DataColumn(label: Text('Received Through')),
        DataColumn(label: Text('Delivered At')),
        DataColumn(label: Text('Content')),
        DataColumn(label: Text('Received By')),
        DataColumn(label: Text('Remarks')),
        DataColumn(label: Text('Assign To')),
        DataColumn(label: Text('Reassign To')),
        DataColumn(label: Text('Re-Reassign To')),
        DataColumn(label: Text('Attachment')),
        DataColumn(label: Text('Actions')),
      ],
      rows: daakList
          .asMap()
          .map((index, daak) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(daak['received_date'] ?? '')),
          DataCell(Text(daak['daak_number'] ?? '')),
          DataCell(Text(daak['daak_from'] ?? '')),
          DataCell(Text(daak['received_through'] ?? '')),
          DataCell(Text(daak['delivered_at'] ?? '')),
          DataCell(Text(daak['content'] ?? '')),
          DataCell(Text(daak['received_by'] ?? '')),
          DataCell(Text(daak['remark'] ?? '')),
          DataCell(Text(daak['assign_to'] ?? '')),
          DataCell(Text(daak['reassign_to'] ?? '')),
          DataCell(Text(daak['re_reassign_to'] ?? '')),
          DataCell(
            daak['attachment'] != null
                ? TextButton(
              onPressed: () {
                // Handle file download
              },
              child: Text('Download'),
            )
                : Text('No File'),
          ),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(daak: daak);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteDaak(daak['id']);
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
        title: Text('Daak Received'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildDaakTable(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateEditDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}
