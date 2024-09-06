import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DaakDispatchedScreen extends StatefulWidget {
  @override
  _DaakDispatchedScreenState createState() => _DaakDispatchedScreenState();
}

class _DaakDispatchedScreenState extends State<DaakDispatchedScreen> {
  List<dynamic> daakList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDaakList();
  }

  Future<void> _fetchDaakList() async {
    final url = Uri.parse('http://localhost:3000/daak-dispatched');
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
    final _dispatchDateController = TextEditingController(text: daak?['dispatch_date']);
    final _daakNumberController = TextEditingController(text: daak?['daak_number']);
    final _dispatchThroughController = TextEditingController(text: daak?['dispatch_through']);
    final _sentToController = TextEditingController(text: daak?['sent_to']);
    final _contentController = TextEditingController(text: daak?['content']);
    final _trackingNumberController = TextEditingController(text: daak?['tracking_number']);
    final _chargesPaidController = TextEditingController(text: daak?['charges_paid']?.toString());
    final _remarkController = TextEditingController(text: daak?['remark']);
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
                controller: _dispatchDateController,
                decoration: InputDecoration(labelText: 'Dispatch Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _dispatchDateController.text = pickedDate.toString().split(' ')[0];
                  }
                },
              ),
              TextField(
                controller: _daakNumberController,
                decoration: InputDecoration(labelText: 'Number Daak'),
              ),
              TextField(
                controller: _dispatchThroughController,
                decoration: InputDecoration(labelText: 'Dispatch Through'),
              ),
              TextField(
                controller: _sentToController,
                decoration: InputDecoration(labelText: 'Sent to'),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
              TextField(
                controller: _trackingNumberController,
                decoration: InputDecoration(labelText: 'Tracking Number'),
              ),
              TextField(
                controller: _chargesPaidController,
                decoration: InputDecoration(labelText: 'Charges Paid'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _remarkController,
                decoration: InputDecoration(labelText: 'Remark'),
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
              final dispatchDate = _dispatchDateController.text;
              final daakNumber = _daakNumberController.text;
              final dispatchThrough = _dispatchThroughController.text;
              final sentTo = _sentToController.text;
              final content = _contentController.text;
              final trackingNumber = _trackingNumberController.text;
              final chargesPaid = _chargesPaidController.text;
              final remark = _remarkController.text;

              if (daak == null) {
                _createDaak(dispatchDate, daakNumber, dispatchThrough, sentTo, content, trackingNumber, chargesPaid, remark, _attachment);
              } else {
                _editDaak(daak['id'], dispatchDate, daakNumber, dispatchThrough, sentTo, content, trackingNumber, chargesPaid, remark, _attachment);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createDaak(String dispatchDate, String daakNumber, String dispatchThrough, String sentTo, String content, String trackingNumber, String chargesPaid, String remark, String? attachment) async {
    final url = Uri.parse('http://localhost:3000/daak-dispatched');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['dispatch_date'] = dispatchDate;
      request.fields['daak_number'] = daakNumber;
      request.fields['dispatch_through'] = dispatchThrough;
      request.fields['sent_to'] = sentTo;
      request.fields['content'] = content;
      request.fields['tracking_number'] = trackingNumber;
      request.fields['charges_paid'] = chargesPaid;
      request.fields['remark'] = remark;

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

  void _editDaak(int id, String dispatchDate, String daakNumber, String dispatchThrough, String sentTo, String content, String trackingNumber, String chargesPaid, String remark, String? attachment) async {
    final url = Uri.parse('http://localhost:3000/daak-dispatched/$id');
    try {
      var request = http.MultipartRequest('PUT', url);
      request.fields['dispatch_date'] = dispatchDate;
      request.fields['daak_number'] = daakNumber;
      request.fields['dispatch_through'] = dispatchThrough;
      request.fields['sent_to'] = sentTo;
      request.fields['content'] = content;
      request.fields['tracking_number'] = trackingNumber;
      request.fields['charges_paid'] = chargesPaid;
      request.fields['remark'] = remark;

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
    final url = Uri.parse('http://localhost:3000/daak-dispatched/$id');
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
        DataColumn(label: Text('Dispatch Date')),
        DataColumn(label: Text('Number Daak')),
        DataColumn(label: Text('Dispatch Through')),
        DataColumn(label: Text('Sent to')),
        DataColumn(label: Text('Content')),
        DataColumn(label: Text('Tracking Number')),
        DataColumn(label: Text('Charges Paid')),
        DataColumn(label: Text('Remarks')),
        DataColumn(label: Text('Attachment')),
        DataColumn(label: Text('Actions')),
      ],
      rows: daakList
          .asMap()
          .map((index, daak) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(daak['dispatch_date'] ?? '')),
          DataCell(Text(daak['daak_number'] ?? '')),
          DataCell(Text(daak['dispatch_through'] ?? '')),
          DataCell(Text(daak['sent_to'] ?? '')),
          DataCell(Text(daak['content'] ?? '')),
          DataCell(Text(daak['tracking_number'] ?? '')),
          DataCell(Text(daak['charges_paid']?.toString() ?? '')),
          DataCell(Text(daak['remark'] ?? '')),
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
        title: Text('Daak Dispatched'),
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
