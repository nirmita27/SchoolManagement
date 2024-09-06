import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaveTypeMasterScreen extends StatefulWidget {
  @override
  _LeaveTypeMasterScreenState createState() => _LeaveTypeMasterScreenState();
}

class _LeaveTypeMasterScreenState extends State<LeaveTypeMasterScreen> {
  List<dynamic> leaveTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaveTypes();
  }

  Future<void> _fetchLeaveTypes() async {
    final url = Uri.parse('http://localhost:3000/leave-types');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          leaveTypes = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load leave types');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch leave types. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? leaveType}) {
    final _nameController = TextEditingController(text: leaveType?['name']);
    final _positiveValueController = TextEditingController(text: leaveType?['positive_value'].toString());
    final _negativeValueController = TextEditingController(text: leaveType?['negative_value'].toString());
    final _startingDelayTimeController = TextEditingController(text: leaveType?['starting_delay_time'].toString());
    final _endingDelayTimeController = TextEditingController(text: leaveType?['ending_delay_time'].toString());
    final _colourCodeController = TextEditingController(text: leaveType?['colour_code']);
    final _textColourController = TextEditingController(text: leaveType?['text_colour']);
    final _nameOnAppController = TextEditingController(text: leaveType?['name_on_app']);
    final _orderNoController = TextEditingController(text: leaveType?['order_no'].toString());
    bool forStaff = leaveType?['for_staff'] ?? false;
    bool forStudent = leaveType?['for_student'] ?? false;
    bool showInLeave = leaveType?['show_in_leave'] ?? false;
    bool showInAttendance = leaveType?['show_in_attendance'] ?? false;
    bool showInLeaveAllowance = leaveType?['show_in_leave_allowance'] ?? false;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  leaveType == null ? 'Add Leave Type' : 'Edit Leave Type',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _positiveValueController,
                  decoration: InputDecoration(labelText: 'Positive Value'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _negativeValueController,
                  decoration: InputDecoration(labelText: 'Negative Value'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _startingDelayTimeController,
                  decoration: InputDecoration(labelText: 'Starting Delay Time (in Minutes)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _endingDelayTimeController,
                  decoration: InputDecoration(labelText: 'Ending Delay Time (in Minutes)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _colourCodeController,
                  decoration: InputDecoration(labelText: 'Colour Code'),
                ),
                TextField(
                  controller: _textColourController,
                  decoration: InputDecoration(labelText: 'Text Colour'),
                ),
                TextField(
                  controller: _nameOnAppController,
                  decoration: InputDecoration(labelText: 'Name On App'),
                ),
                TextField(
                  controller: _orderNoController,
                  decoration: InputDecoration(labelText: 'Order No'),
                  keyboardType: TextInputType.number,
                ),
                CheckboxListTile(
                  title: Text('For Staff'),
                  value: forStaff,
                  onChanged: (value) {
                    setState(() {
                      forStaff = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('For Student'),
                  value: forStudent,
                  onChanged: (value) {
                    setState(() {
                      forStudent = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Show In Leave'),
                  value: showInLeave,
                  onChanged: (value) {
                    setState(() {
                      showInLeave = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Show In Attendance'),
                  value: showInAttendance,
                  onChanged: (value) {
                    setState(() {
                      showInAttendance = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Show In Leave Allowance'),
                  value: showInLeaveAllowance,
                  onChanged: (value) {
                    setState(() {
                      showInLeaveAllowance = value!;
                    });
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    ElevatedButton(
                      child: Text(leaveType == null ? 'Add' : 'Save'),
                      onPressed: () {
                        final name = _nameController.text;
                        final positiveValue = double.parse(_positiveValueController.text);
                        final negativeValue = double.parse(_negativeValueController.text);
                        final startingDelayTime = int.parse(_startingDelayTimeController.text);
                        final endingDelayTime = int.parse(_endingDelayTimeController.text);
                        final colourCode = _colourCodeController.text;
                        final textColour = _textColourController.text;
                        final nameOnApp = _nameOnAppController.text;
                        final orderNo = int.parse(_orderNoController.text);

                        if (leaveType == null) {
                          _createLeaveType(
                            name,
                            positiveValue,
                            negativeValue,
                            startingDelayTime,
                            endingDelayTime,
                            colourCode,
                            textColour,
                            nameOnApp,
                            orderNo,
                            forStaff,
                            forStudent,
                            showInLeave,
                            showInAttendance,
                            showInLeaveAllowance,
                          );
                        } else {
                          _editLeaveType(
                            leaveType['id'],
                            name,
                            positiveValue,
                            negativeValue,
                            startingDelayTime,
                            endingDelayTime,
                            colourCode,
                            textColour,
                            nameOnApp,
                            orderNo,
                            forStaff,
                            forStudent,
                            showInLeave,
                            showInAttendance,
                            showInLeaveAllowance,
                          );
                        }
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createLeaveType(
      String name,
      double positiveValue,
      double negativeValue,
      int startingDelayTime,
      int endingDelayTime,
      String colourCode,
      String textColour,
      String nameOnApp,
      int orderNo,
      bool forStaff,
      bool forStudent,
      bool showInLeave,
      bool showInAttendance,
      bool showInLeaveAllowance,
      ) async {
    final url = Uri.parse('http://localhost:3000/leave-types');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'positive_value': positiveValue,
          'negative_value': negativeValue,
          'starting_delay_time': startingDelayTime,
          'ending_delay_time': endingDelayTime,
          'colour_code': colourCode,
          'text_colour': textColour,
          'name_on_app': nameOnApp,
          'order_no': orderNo,
          'for_staff': forStaff,
          'for_student': forStudent,
          'show_in_leave': showInLeave,
          'show_in_attendance': showInAttendance,
          'show_in_leave_allowance': showInLeaveAllowance,
        }),
      );
      if (response.statusCode == 201) {
        _fetchLeaveTypes();
      } else {
        throw Exception('Failed to create leave type');
      }
    } catch (error) {
      _showErrorDialog('Failed to create leave type. Please try again.');
    }
  }

  void _editLeaveType(
      int id,
      String name,
      double positiveValue,
      double negativeValue,
      int startingDelayTime,
      int endingDelayTime,
      String colourCode,
      String textColour,
      String nameOnApp,
      int orderNo,
      bool forStaff,
      bool forStudent,
      bool showInLeave,
      bool showInAttendance,
      bool showInLeaveAllowance,
      ) async {
    final url = Uri.parse('http://localhost:3000/leave-types/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'positive_value': positiveValue,
          'negative_value': negativeValue,
          'starting_delay_time': startingDelayTime,
          'ending_delay_time': endingDelayTime,
          'colour_code': colourCode,
          'text_colour': textColour,
          'name_on_app': nameOnApp,
          'order_no': orderNo,
          'for_staff': forStaff,
          'for_student': forStudent,
          'show_in_leave': showInLeave,
          'show_in_attendance': showInAttendance,
          'show_in_leave_allowance': showInLeaveAllowance,
        }),
      );
      if (response.statusCode == 200) {
        _fetchLeaveTypes();
      } else {
        throw Exception('Failed to edit leave type');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit leave type. Please try again.');
    }
  }

  void _deleteLeaveType(int id) async {
    final url = Uri.parse('http://localhost:3000/leave-types/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchLeaveTypes();
      } else {
        throw Exception('Failed to delete leave type');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete leave type. Please try again.');
    }
  }

  void _showUserTypesDialog(List<dynamic> userTypes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: userTypes.map<Widget>((userType) {
                return Text('${userType['id']} - ${userType['name']}');
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveTypeTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Positive Value')),
        DataColumn(label: Text('Negative Value')),
        DataColumn(label: Text('User Type')),
        DataColumn(label: Text('Actions')),
      ],
      rows: leaveTypes
          .asMap()
          .map((index, leaveType) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(leaveType['name'] ?? '')),
          DataCell(Text(leaveType['positive_value'].toString())),
          DataCell(Text(leaveType['negative_value'].toString())),
          DataCell(
            InkWell(
              child: Text('View', style: TextStyle(color: Colors.blue)),
              onTap: () {
                _showUserTypesDialog(leaveType['user_types']);
              },
            ),
          ),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(leaveType: leaveType);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteLeaveType(leaveType['id']);
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
        title: Text('Leave Type Master'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildLeaveTypeTable(),
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
