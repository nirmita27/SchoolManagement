import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FuelFillingForm extends StatefulWidget {
  final Map<String, dynamic>? editFuelFilling;

  FuelFillingForm({this.editFuelFilling});

  @override
  _FuelFillingFormState createState() => _FuelFillingFormState();
}

class _FuelFillingFormState extends State<FuelFillingForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vehicleNameController;
  late TextEditingController _fuelFillingDateController;
  late TextEditingController _meterReadingController;
  late TextEditingController _quantityController;
  late TextEditingController _fuelPriceController;
  late TextEditingController _slipNumberController;

  @override
  void initState() {
    super.initState();
    _vehicleNameController = TextEditingController(text: widget.editFuelFilling?['vehicle_name'] ?? '');
    _fuelFillingDateController = TextEditingController(text: widget.editFuelFilling?['fuel_filling_date'] ?? '');
    _meterReadingController = TextEditingController(text: widget.editFuelFilling?['meter_reading']?.toString() ?? '');
    _quantityController = TextEditingController(text: widget.editFuelFilling?['quantity']?.toString() ?? '');
    _fuelPriceController = TextEditingController(text: widget.editFuelFilling?['fuel_price']?.toString() ?? '');
    _slipNumberController = TextEditingController(text: widget.editFuelFilling?['slip_number'] ?? '');
  }

  Future<void> saveFuelFilling() async {
    if (_formKey.currentState?.validate() ?? false) {
      final fuelFilling = {
        'vehicle_name': _vehicleNameController.text,
        'fuel_filling_date': _fuelFillingDateController.text,
        'meter_reading': int.parse(_meterReadingController.text),
        'quantity': double.parse(_quantityController.text),
        'fuel_price': double.parse(_fuelPriceController.text),
        'slip_number': _slipNumberController.text,
      };

      final response = widget.editFuelFilling == null
          ? await http.post(
        Uri.parse('http://localhost:3000/fuel-fillings'), // Replace with your actual backend URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode(fuelFilling),
      )
          : await http.put(
        Uri.parse('http://localhost:3000/fuel-fillings/${widget.editFuelFilling!['id']}'), // Replace with your actual backend URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode(fuelFilling),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save fuel filling detail.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editFuelFilling == null ? 'Add Fuel Filling' : 'Edit Fuel Filling'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _vehicleNameController,
                decoration: InputDecoration(labelText: 'Vehicle Name'),
                validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
              ),
              TextFormField(
                controller: _fuelFillingDateController,
                decoration: InputDecoration(labelText: 'Fuel Filling Date'),
                validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
              ),
              TextFormField(
                controller: _meterReadingController,
                decoration: InputDecoration(labelText: 'Meter Reading'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
              ),
              TextFormField(
                controller: _fuelPriceController,
                decoration: InputDecoration(labelText: 'Fuel Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
              ),
              TextFormField(
                controller: _slipNumberController,
                decoration: InputDecoration(labelText: 'Slip Number'),
                validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveFuelFilling,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}