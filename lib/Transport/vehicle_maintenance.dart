import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'vehicle_maintenance_form.dart';

class VehicleMaintenanceScreen extends StatefulWidget {
  @override
  _VehicleMaintenanceScreenState createState() => _VehicleMaintenanceScreenState();
}

class _VehicleMaintenanceScreenState extends State<VehicleMaintenanceScreen> {
  List<Map<String, dynamic>> maintenanceEntries = [];

  Future<void> fetchMaintenanceEntries() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/vehicle-maintenance'), // Replace with your actual backend URL
    );

    if (response.statusCode == 200) {
      setState(() {
        maintenanceEntries = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch maintenance entries.')),
      );
    }
  }

  Future<void> deleteMaintenanceEntry(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/vehicle-maintenance/$id'), // Replace with your actual backend URL
    );

    if (response.statusCode == 204) {
      fetchMaintenanceEntries();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete maintenance entry.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMaintenanceEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Maintenance'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VehicleMaintenanceForm()),
              ).then((_) {
                fetchMaintenanceEntries(); // Refresh the list after adding/editing
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: maintenanceEntries.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              child: DataTable(
                columnSpacing: 12,
                headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade700),
                columns: [
                  DataColumn(label: Text('Maintenance Name', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Vehicle Name', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Maintenance Date', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white))),
                ],
                rows: maintenanceEntries.map((entry) {
                  return DataRow(cells: [
                    DataCell(Text(entry['maintenance_name'])),
                    DataCell(Text(entry['vehicle_name'])),
                    DataCell(Text(entry['maintenance_date'].split('T')[0])), // Remove the time part
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Navigate to edit screen with selected maintenance entry
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => VehicleMaintenanceForm(editEntry: entry)),
                            ).then((_) {
                              fetchMaintenanceEntries(); // Refresh the list after editing
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteMaintenanceEntry(entry['id']),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}