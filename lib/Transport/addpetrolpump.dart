import 'package:flutter/material.dart';
import 'api_service.dart';

class AddPetrolPumpScreen extends StatefulWidget {
  final Function onAdd;

  AddPetrolPumpScreen({required this.onAdd});

  @override
  _AddPetrolPumpScreenState createState() => _AddPetrolPumpScreenState();
}

class _AddPetrolPumpScreenState extends State<AddPetrolPumpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serialNumberController = TextEditingController();
  final _pumpNameController = TextEditingController();
  final _addressController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newPump = {
        'serial_number': int.parse(_serialNumberController.text),
        'pump_name': _pumpNameController.text,
        'address': _addressController.text,
      };

      try {
        await ApiService.addPetrolPump(newPump);
        widget.onAdd();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add petrol pump: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Petrol Pump'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _serialNumberController,
                decoration: InputDecoration(labelText: 'Serial Number'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the serial number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pumpNameController,
                decoration: InputDecoration(labelText: 'Pump Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the pump name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}