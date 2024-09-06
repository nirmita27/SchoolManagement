import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleInsuranceScreen extends StatefulWidget {
  @override
  _VehicleInsuranceScreenState createState() => _VehicleInsuranceScreenState();
}

class _VehicleInsuranceScreenState extends State<VehicleInsuranceScreen> {
  List<Map<String, dynamic>> insurances = [];

  Future<void> fetchInsurances() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/insurance'), // Update with your actual backend URL
    );

    if (response.statusCode == 200) {
      setState(() {
        insurances = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch insurance details.')),
      );
    }
  }

  Future<void> addInsurance(Map<String, dynamic> insurance) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/insurance'), // Update with your actual backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode(insurance),
    );

    if (response.statusCode == 201) {
      fetchInsurances();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add insurance detail.')),
      );
    }
  }

  Future<void> updateInsurance(int id, Map<String, dynamic> insurance) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/insurance/$id'), // Update with your actual backend URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode(insurance),
    );

    if (response.statusCode == 200) {
      fetchInsurances();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update insurance detail.')),
      );
    }
  }

  Future<void> deleteInsurance(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/insurance/$id'), // Update with your actual backend URL
    );

    if (response.statusCode == 200) {
      fetchInsurances();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete insurance detail.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInsurances();
  }

  void _showAddInsuranceForm() {
    final _vehicleNameController = TextEditingController();
    final _startDateController = TextEditingController();
    final _endDateController = TextEditingController();
    final _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Insurance Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vehicleNameController,
                decoration: InputDecoration(labelText: 'Vehicle Name'),
              ),
              TextField(
                controller: _startDateController,
                decoration: InputDecoration(labelText: 'Insurance Start Date'),
              ),
              TextField(
                controller: _endDateController,
                decoration: InputDecoration(labelText: 'Insurance End Date'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Insurance Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
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
                final insurance = {
                  'vehicle_name': _vehicleNameController.text,
                  'start_date': _startDateController.text,
                  'end_date': _endDateController.text,
                  'amount': _amountController.text,
                };
                addInsurance(insurance);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditInsuranceForm(Map<String, dynamic> insurance) {
    final _vehicleNameController = TextEditingController(text: insurance['vehicle_name']);
    final _startDateController = TextEditingController(text: insurance['start_date']);
    final _endDateController = TextEditingController(text: insurance['end_date']);
    final _amountController = TextEditingController(text: insurance['amount'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Insurance Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vehicleNameController,
                decoration: InputDecoration(labelText: 'Vehicle Name'),
              ),
              TextField(
                controller: _startDateController,
                decoration: InputDecoration(labelText: 'Insurance Start Date'),
              ),
              TextField(
                controller: _endDateController,
                decoration: InputDecoration(labelText: 'Insurance End Date'),
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Insurance Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
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
                final updatedInsurance = {
                  'vehicle_name': _vehicleNameController.text,
                  'start_date': _startDateController.text,
                  'end_date': _endDateController.text,
                  'amount': _amountController.text,
                };
                updateInsurance(insurance['id'], updatedInsurance);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Insurance'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddInsuranceForm,
          ),
        ],
      ),
      body: insurances.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          border: TableBorder.all(color: Colors.blueAccent, width: 2),
          columns: [
            DataColumn(label: Text('Vehicle Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('End Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: insurances.map((insurance) {
            return DataRow(cells: [
              DataCell(Text(insurance['vehicle_name'])),
              DataCell(Text(insurance['start_date'].split('T')[0])),
              DataCell(Text(insurance['end_date'].split('T')[0])),
              DataCell(Text(insurance['amount'].toString())),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditInsuranceForm(insurance),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => deleteInsurance(insurance['id']),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}