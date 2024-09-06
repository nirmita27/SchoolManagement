import 'package:flutter/material.dart';
import 'api_service.dart';

class VendorMasterScreen extends StatefulWidget {
  @override
  _VendorMasterScreenState createState() => _VendorMasterScreenState();
}

class _VendorMasterScreenState extends State<VendorMasterScreen> {
  List<Map<String, dynamic>> _vendors = [];

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    try {
      List<dynamic> vendorsData = await ApiService.getVendors();
      List<Map<String, dynamic>> vendors = vendorsData.map((vendor) => vendor as Map<String, dynamic>).toList();
      setState(() {
        _vendors = vendors;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vendors: $e')),
      );
    }
  }

  Future<void> _deleteVendor(int serialNumber) async {
    try {
      await ApiService.deleteVendor(serialNumber);

      setState(() {
        _vendors.removeWhere((vendor) => vendor['serial_number'] == serialNumber);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vendor deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete vendor: $e')),
      );
    }
  }

  void _addVendor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddVendorScreen(onAdd: _fetchVendors)),
    );
  }

  void _editVendor(Map<String, dynamic> vendor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditVendorScreen(vendor: vendor, onEdit: _fetchVendors)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Master'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addVendor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
            ),
            child: DataTable(
              headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade100),
              dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
              columnSpacing: 16.0,
              border: TableBorder.all(color: Colors.blue, width: 1),
              columns: [
                DataColumn(label: Text('Serial Number', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Vendor Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Order Number', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              ],
              rows: _vendors.map((vendor) {
                return DataRow(
                  cells: [
                    DataCell(Text(vendor['serial_number'].toString(), style: TextStyle(color: Colors.black))),
                    DataCell(Text(vendor['vendor_name'], style: TextStyle(color: Colors.black))),
                    DataCell(Text(vendor['order_number'], style: TextStyle(color: Colors.black))),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            _editVendor(vendor);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text('Are you sure you want to delete ${vendor['vendor_name']}?'),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Delete'),
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await _deleteVendor(vendor['serial_number']);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class AddVendorScreen extends StatefulWidget {
  final Function onAdd;

  AddVendorScreen({required this.onAdd});

  @override
  _AddVendorScreenState createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'vendor_name': '',
    'order_number': '',
  };

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        await ApiService.addVendor(_formData);
        widget.onAdd();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add vendor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vendor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Vendor Name'),
                onSaved: (value) {
                  _formData['vendor_name'] = value;
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a vendor name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Order Number'),
                onSaved: (value) {
                  _formData['order_number'] = value;
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an order number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Vendor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditVendorScreen extends StatefulWidget {
  final Map<String, dynamic> vendor;
  final Function onEdit;

  EditVendorScreen({required this.vendor, required this.onEdit});

  @override
  _EditVendorScreenState createState() => _EditVendorScreenState();
}

class _EditVendorScreenState extends State<EditVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.vendor);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        await ApiService.updateVendor(_formData['serial_number'], _formData);
        widget.onEdit();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update vendor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Vendor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _formData['vendor_name'],
                decoration: InputDecoration(labelText: 'Vendor Name'),
                onSaved: (value) {
                  _formData['vendor_name'] = value;
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a vendor name';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _formData['order_number'],
                decoration: InputDecoration(labelText: 'Order Number'),
                onSaved: (value) {
                  _formData['order_number'] = value;
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an order number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Update Vendor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}