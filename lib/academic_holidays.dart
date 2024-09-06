import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AcademicCalendarScreen extends StatefulWidget {
  @override
  _AcademicCalendarScreenState createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  List<Map<String, dynamic>> holidays = [];
  List<Map<String, dynamic>> holidayMaster = [];
  final String apiUrl = 'http://localhost:3000/holidays'; // Adjust based on your server's URL
  final String holidayMasterUrl = 'http://localhost:3000/holiday_master'; // URL for fetching holiday master data
  String selectedFinancialYear = '2024-2025'; // Initial financial year selection

  @override
  void initState() {
    super.initState();
    _fetchHolidayMaster(); // Fetch holiday master data
    _fetchHolidays(selectedFinancialYear); // Fetch holidays for the initial financial year
  }

  Future<void> _fetchHolidayMaster() async {
    try {
      final response = await http.get(Uri.parse(holidayMasterUrl));
      if (response.statusCode == 200) {
        setState(() {
          holidayMaster = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Failed to load holiday master data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching holiday master data: $e');
    }
  }

  Future<void> _fetchHolidays(String financialYear) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl?financialYear=$financialYear'));
      if (response.statusCode == 200) {
        setState(() {
          holidays = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Failed to load holidays: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching holidays: $e');
    }
  }

  Future<void> _addHoliday(int nameId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name_id': nameId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String()
        }),
      );
      if (response.statusCode == 201) {
        _fetchHolidays(selectedFinancialYear); // Refresh the list after adding
      } else {
        print('Failed to add holiday: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding holiday: $e');
    }
  }

  Future<void> _editHoliday(int id, int nameId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name_id': nameId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String()
        }),
      );
      if (response.statusCode == 200) {
        _fetchHolidays(selectedFinancialYear); // Refresh the list after editing
      } else {
        print('Failed to edit holiday: ${response.statusCode}');
      }
    } catch (e) {
      print('Error editing holiday: $e');
    }
  }

  Future<void> _deleteHoliday(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 204) {
        _fetchHolidays(selectedFinancialYear); // Refresh the list after deleting
      } else {
        print('Failed to delete holiday: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting holiday: $e');
    }
  }

  void _showAddHolidayDialog() {
    int? selectedNameId;
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Holiday (छुट्टी जोड़ें)'),
          content: Container(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Holiday Name (छुट्टी का नाम)',
                    border: OutlineInputBorder(),
                  ),
                  items: holidayMaster.map((holiday) {
                    return DropdownMenuItem<int>(
                      value: holiday['id'],
                      child: Text(holiday['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedNameId = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedStartDate = picked;
                      });
                    }
                  },
                  child: Text('Pick Start Date (आरंभ तिथि चुनें)'),
                ),
                if (selectedStartDate != null)
                  Text('Selected start date: ${selectedStartDate!.toString().split(' ')[0]}'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedEndDate = picked;
                      });
                    }
                  },
                  child: Text('Pick End Date (समाप्ति तिथि चुनें)'),
                ),
                if (selectedEndDate != null)
                  Text('Selected end date: ${selectedEndDate!.toString().split(' ')[0]}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedNameId != null &&
                    selectedStartDate != null &&
                    selectedEndDate != null) {
                  _addHoliday(selectedNameId!, selectedStartDate!, selectedEndDate!);
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Validation Error (मान्यता त्रुटि)'),
                      content: Text('Please fill in all fields and select dates.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditHolidayDialog(int id, int nameId, DateTime startDate, DateTime endDate) {
    int? selectedNameId = nameId;
    DateTime? selectedStartDate = startDate;
    DateTime? selectedEndDate = endDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Holiday (छुट्टियाँ संपादित करें)'),
          content: Container(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Holiday Name (छुट्टी का नाम)',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedNameId,
                  items: holidayMaster.map((holiday) {
                    return DropdownMenuItem<int>(
                      value: holiday['id'],
                      child: Text(holiday['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedNameId = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedStartDate = picked;
                      });
                    }
                  },
                  child: Text('Pick Start Date (आरंभ तिथि चुनें)'),
                ),
                if (selectedStartDate != null)
                  Text('Selected start date: ${selectedStartDate!.toString().split(' ')[0]}'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedEndDate = picked;
                      });
                    }
                  },
                  child: Text('Pick End Date (समाप्ति तिथि चुनें)'),
                ),
                if (selectedEndDate != null)
                  Text('Selected end date: ${selectedEndDate!.toString().split(' ')[0]}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedNameId != null &&
                    selectedStartDate != null &&
                    selectedEndDate != null) {
                  _editHoliday(id, selectedNameId!, selectedStartDate!, selectedEndDate!);
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Validation Error'),
                      content: Text('Please fill in all fields and select dates.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteHolidayDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Holiday (छुट्टियाँ हटाएँ)'),
          content: Text('Are you sure you want to delete this holiday?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteHoliday(id);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd'); // Date format

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Academic Calendar (शैक्षणिक कैलेंडर)'),
            Spacer(),
            DropdownButton<String>(
              value: selectedFinancialYear,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedFinancialYear = newValue;
                    _fetchHolidays(selectedFinancialYear); // Fetch holidays for the selected financial year
                  });
                }
              },
              items: <String>[
                '2022-2023',
                '2023-2024',
                '2024-2025',
                // Add more financial years as needed
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade200],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataTable(
                columnSpacing: 20,
                columns: [
                  DataColumn(
                    label: Text(
                      'Holiday Name (छुट्टी का नाम)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Type (छुट्टी का प्रकार)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Start Date (आरंभ करने की तिथि)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'End Date (अंतिम तिथि)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions (कार्रवाई)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                ],
                rows: holidays.asMap().entries.map((holiday) {
                  final int index = holiday.key;
                  final Map<String, dynamic>? data = holiday.value; // Use nullable type for data

                  // Handle null case
                  if (data == null) {
                    return DataRow(cells: [
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                      DataCell(Text('')),
                    ]);
                  }

                  // Ensure all properties are not null before accessing
                  final name = data['holiday_name'] ?? 'No Name';
                  final type = data['holiday_type'] ?? 'Unknown Type';
                  final startDate = data['start_date'] != null ? DateTime.parse(data['start_date']) : DateTime.now();
                  final endDate = data['end_date'] != null ? DateTime.parse(data['end_date']) : DateTime.now();

                  final textColor = Colors.black;
                  final backgroundColor = (type == 'National Holiday') ? Colors.yellow.shade200 : Colors.white;

                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        return backgroundColor; // Set the background color
                      },
                    ),
                    cells: [
                      DataCell(Text(name, style: TextStyle(color: textColor))),
                      DataCell(Text(type, style: TextStyle(color: textColor))),
                      DataCell(Text(dateFormatter.format(startDate), style: TextStyle(color: textColor))),
                      DataCell(Text(dateFormatter.format(endDate), style: TextStyle(color: textColor))),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showEditHolidayDialog(
                                  data['id'],
                                  data['name_id'],
                                  startDate,
                                  endDate,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteHolidayDialog(data['id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHolidayDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
