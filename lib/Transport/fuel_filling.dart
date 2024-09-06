import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'fuel_filling_form.dart';

class FuelFillingScreen extends StatefulWidget {
  @override
  _FuelFillingScreenState createState() => _FuelFillingScreenState();
}

class _FuelFillingScreenState extends State<FuelFillingScreen> {
  List<Map<String, dynamic>> fuelFillings = [];

  Future<void> fetchFuelFillings() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/fuel-fillings'), // Replace with your actual backend URL
    );

    if (response.statusCode == 200) {
      setState(() {
        fuelFillings = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch fuel filling details.')),
      );
    }
  }

  Future<void> deleteFuelFilling(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/fuel-fillings/$id'), // Replace with your actual backend URL
    );

    if (response.statusCode == 200) {
      fetchFuelFillings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete fuel filling detail.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFuelFillings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Filling Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FuelFillingForm()),
              ).then((_) {
                fetchFuelFillings(); // Refresh the list after adding/editing
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
          child: fuelFillings.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                      child: DataTable(
                        columnSpacing: 12,
                        headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.blue.shade700),
                        columns: [
                          DataColumn(
                              label: Text('Serial No',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Vehicle Name',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Fuel Filling Date',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Meter Reading',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Quantity',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Fuel Price',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Actions',
                                  style: TextStyle(color: Colors.white))),
                        ],
                        rows: fuelFillings.map((fuelFilling) {
                          return DataRow(cells: [
                            DataCell(
                                Text(fuelFilling['serial_no'].toString())),
                            DataCell(Text(fuelFilling['vehicle_name'])),
                            DataCell(Text(fuelFilling['fuel_filling_date']
                                .split('T')[0])), // Remove the time part
                            DataCell(Text(
                                fuelFilling['meter_reading'].toString())),
                            DataCell(
                                Text(fuelFilling['quantity'].toString())),
                            DataCell(
                                Text(fuelFilling['fuel_price'].toString())),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    // Navigate to edit screen with selected fuel filling
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FuelFillingForm(
                                                  editFuelFilling:
                                                  fuelFilling)),
                                    ).then((_) {
                                      fetchFuelFillings(); // Refresh the list after editing
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      deleteFuelFilling(fuelFilling['id']),
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
            ],
          ),
        ),
      ),
    );
  }
}