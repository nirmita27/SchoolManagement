import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleMaintenanceForm extends StatefulWidget {
  final Map<String, dynamic>? editEntry;

  VehicleMaintenanceForm({this.editEntry});

  @override
  _VehicleMaintenanceFormState createState() => _VehicleMaintenanceFormState();
}

class _VehicleMaintenanceFormState extends State<VehicleMaintenanceForm> {
  final _formKey = GlobalKey<FormState>();
  String? _vehicleName;
  String? _maintenanceDate;
  String? _maintenanceName;
  int? _meterReading;
  List<Map<String, dynamic>> _details = [];

  @override
  void initState() {
    super.initState();
    if (widget.editEntry != null) {
      _vehicleName = widget.editEntry!['vehicle_name'];
      _maintenanceDate = widget.editEntry!['maintenance_date'];
      _maintenanceName = widget.editEntry!['maintenance_name'];
      _meterReading = widget.editEntry!['meter_reading'];
      fetchMaintenanceDetails(widget.editEntry!['id']);
    }
  }

  Future<void> fetchMaintenanceDetails(int maintenanceId) async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/maintenance-details/$maintenanceId'), // Replace with your actual backend URL
    );

    if (response.statusCode == 200) {
      setState(() {
        _details = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch maintenance details.')),
      );
    }
  }

  Future<void> saveMaintenance() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final data = {
        'vehicle_name': _vehicleName,
        'maintenance_date': _maintenanceDate,
        'maintenance_name': _maintenanceName,
        'meter_reading': _meterReading,
        'details': _details
      };

      final url = widget.editEntry == null
          ? 'http://localhost:3000/vehicle-maintenance'
          : 'http://localhost:3000/vehicle-maintenance/${widget.editEntry!['id']}';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save maintenance entry.')),
        );
      }
    }
  }

  void _addDetail() {
    setState(() {
      _details.add({
        'date': '',
        'bill_number': '',
        'vendor_name': '',
        'amount': 0.0,
      });
    });
  }

  void _removeDetail(int index) {
    setState(() {
      _details.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editEntry == null ? 'Add Maintenance' : 'Edit Maintenance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle Name'),
                  initialValue: _vehicleName,
                  validator: (value) => value!.isEmpty ? 'Enter vehicle name' : null,
                  onSaved: (value) => _vehicleName = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Maintenance Date'),
                  initialValue: _maintenanceDate,
                  validator: (value) => value!.isEmpty ? 'Enter maintenance date' : null,
                  onSaved: (value) => _maintenanceDate = value,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Maintenance Name'),
                  value: _maintenanceName,
                  items: ['Regular', 'Electric', 'Emergency', 'Washing', 'Tyre Puncture', 'Battery']
                      .map((name) => DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  ))
                      .toList(),
                  validator: (value) => value == null ? 'Select maintenance name' : null,
                  onChanged: (value) => setState(() => _maintenanceName = value),
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Meter Reading'),
                  initialValue: _meterReading?.toString(),
                  validator: (value) => value!.isEmpty ? 'Enter meter reading' : null,
                  onSaved: (value) => _meterReading = int.parse(value!),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Text('Maintenance Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _details.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Date'),
                              initialValue: _details[index]['date'],
                              validator: (value) => value!.isEmpty ? 'Enter date' : null,
                              onSaved: (value) => _details[index]['date'] = value,
                            ),
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Bill Number'),
                              initialValue: _details[index]['bill_number'],
                              validator: (value) => value!.isEmpty ? 'Enter bill number' : null,
                              onSaved: (value) => _details[index]['bill_number'] = value,
                            ),
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Vendor Name'),
                              initialValue: _details[index]['vendor_name'],
                              validator: (value) => value!.isEmpty ? 'Enter vendor name' : null,
                              onSaved: (value) => _details[index]['vendor_name'] = value,
                            ),
                            TextFormField(
                              decoration: InputDecoration(labelText: 'Amount'),
                              initialValue: _details[index]['amount'].toString(),
                              validator: (value) => value!.isEmpty ? 'Enter amount' : null,
                              onSaved: (value) => _details[index]['amount'] = double.parse(value!),
                              keyboardType: TextInputType.number,
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeDetail(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton(onPressed: _addDetail, child: Text('Add Detail')),
                SizedBox(height: 20),
                ElevatedButton(onPressed: saveMaintenance, child: Text('Save')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}