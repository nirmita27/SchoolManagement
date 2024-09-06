import 'package:flutter/material.dart';
import 'api_service.dart';

class BusStopMasterScreen extends StatefulWidget {
  @override
  _BusStopMasterScreenState createState() => _BusStopMasterScreenState();
}

class _BusStopMasterScreenState extends State<BusStopMasterScreen> {
  List<Map<String, dynamic>> _busStops = [];

  @override
  void initState() {
    super.initState();
    _fetchBusStops();
  }

  Future<void> _fetchBusStops() async {
    try {
      List<dynamic> busStopsData = await ApiService.getBusStops();
      List<Map<String, dynamic>> busStops = busStopsData.map((busStop) => busStop as Map<String, dynamic>).toList();
      setState(() {
        _busStops = busStops;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bus stops: $e')),
      );
    }
  }

  Future<void> _deleteBusStop(int serialNumber) async {
    try {
      await ApiService.deleteBusStop(serialNumber);

      setState(() {
        _busStops.removeWhere((busStop) => busStop['serial_number'] == serialNumber);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus stop deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete bus stop: $e')),
      );
    }
  }

  void _addBusStop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddBusStopScreen(onAdd: _fetchBusStops)),
    );
  }

  void _editBusStop(Map<String, dynamic> busStop) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBusStopScreen(busStop: busStop, onEdit: _fetchBusStops)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Stop Master'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addBusStop,
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
                DataColumn(label: Text('Bus Stop Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Distance from School', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Area', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Route Information', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              ],
              rows: _busStops.map((busStop) {
                return DataRow(
                  cells: [
                    DataCell(Text(busStop['serial_number'].toString(), style: TextStyle(color: Colors.black))),
                    DataCell(Text(busStop['bus_stop_name'], style: TextStyle(color: Colors.black))),
                    DataCell(Text(busStop['distance_from_school'].toString(), style: TextStyle(color: Colors.black))),
                    DataCell(Text(busStop['area'], style: TextStyle(color: Colors.black))),
                    DataCell(Text(busStop['route_information'], style: TextStyle(color: Colors.black))),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            _editBusStop(busStop);
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
                                  content: Text('Are you sure you want to delete ${busStop['bus_stop_name']}?'),
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
                                        await _deleteBusStop(busStop['serial_number']);
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

class AddBusStopScreen extends StatefulWidget {
  final Function onAdd;

  AddBusStopScreen({required this.onAdd});

  @override
  _AddBusStopScreenState createState() => _AddBusStopScreenState();
}

class _AddBusStopScreenState extends State<AddBusStopScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'bus_stop_name': '',
    'distance_from_school': '',
    'area': '',
    'route_information': '',
  };

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        await ApiService.addBusStop(_formData);
        widget.onAdd();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add bus stop: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Add Bus Stop'),
    ),
    body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Form(
    key: _formKey,
    child: ListView(
    children: [
    TextFormField(
    decoration: InputDecoration(labelText: 'Bus Stop Name'),
    onSaved: (value) {
    _formData['bus_stop_name'] = value;
    },
    validator: (value) {
    if (value?.isEmpty ?? true) {
    return 'Please enter a bus stop name';
    }
    return null;
    },
    ),
    TextFormField(
    decoration: InputDecoration(labelText: 'Distance from School'),
    onSaved: (value) {
    _formData['distance_from_school'] = value;
    },
    validator: (value) {
    if (value?.isEmpty ?? true) {
    return 'Please enter the distance from school';
    }
    return null;
    },
    ),
    TextFormField(
    decoration: InputDecoration(labelText: 'Area'),
    onSaved: (value) {
    _formData['area'] = value;
    },
    validator: (value) {
      if (value?.isEmpty ?? true) {
        return 'Please enter the area';
      }
      return null;
    },
    ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Route Information'),
        onSaved: (value) {
          _formData['route_information'] = value;
        },
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Please enter the route information';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: _submitForm,
        child: Text('Add Bus Stop'),
      ),
    ],
    ),
    ),
    ),
    );
  }
}

class EditBusStopScreen extends StatefulWidget {
  final Map<String, dynamic> busStop;
  final Function onEdit;

  EditBusStopScreen({required this.busStop, required this.onEdit});

  @override
  _EditBusStopScreenState createState() => _EditBusStopScreenState();
}

class _EditBusStopScreenState extends State<EditBusStopScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = {
      'bus_stop_name': widget.busStop['bus_stop_name'],
      'distance_from_school': widget.busStop['distance_from_school'].toString(),
      'area': widget.busStop['area'],
      'route_information': widget.busStop['route_information'],
    };
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        // Call API service to update bus stop
        // await ApiService.updateBusStop(widget.busStop['serial_number'], _formData);
        widget.onEdit();
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update bus stop: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Bus Stop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _formData['bus_stop_name'],
                decoration: InputDecoration(labelText: 'Bus Stop Name'),
                onSaved: (value) {
                  _formData['bus_stop_name'] = value;
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a bus stop name';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _formData['distance_from_school'],
                decoration: InputDecoration(labelText: 'Distance from School'),
                onSaved: (value) {
                  _formData['distance_from_school'] = value;
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the distance from school';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _formData['area'],
                decoration: InputDecoration(labelText: 'Area'),
                onSaved: (value) {
                  _formData['area'] = value;
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the area';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _formData['route_information'],
                decoration: InputDecoration(labelText: 'Route Information'),
                onSaved: (value) {
                  _formData['route_information'] = value;
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the route information';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Update Bus Stop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}