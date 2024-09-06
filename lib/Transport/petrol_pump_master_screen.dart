import 'package:flutter/material.dart';
import 'api_service.dart';
import 'addpetrolpump.dart';

class PetrolPumpMasterScreen extends StatefulWidget {
  @override
  _PetrolPumpMasterScreenState createState() => _PetrolPumpMasterScreenState();
}

class _PetrolPumpMasterScreenState extends State<PetrolPumpMasterScreen> {
  List<Map<String, dynamic>> _petrolPumps = [];

  @override
  void initState() {
    super.initState();
    _fetchPetrolPumps();
  }

  Future<void> _fetchPetrolPumps() async {
    try {
      List<dynamic> pumpsData = await ApiService.getPetrolPumps();
      List<Map<String, dynamic>> pumps = pumpsData.map((pump) => pump as Map<String, dynamic>).toList();
      setState(() {
        _petrolPumps = pumps;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load petrol pumps: $e')),
      );
    }
  }

  Future<void> _deletePetrolPump(int serialNumber) async {
    try {
      await ApiService.deletePetrolPump(serialNumber);

      setState(() {
        _petrolPumps.removeWhere((pump) => pump['serial_number'] == serialNumber);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Petrol pump deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete petrol pump: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Petrol Pump Master'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPetrolPumpScreen(onAdd: _fetchPetrolPumps)),
              );
            },
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
                DataColumn(label: Text('Pump Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              ],
              rows: _petrolPumps.map((pump) {
                return DataRow(
                  cells: [
                    DataCell(Text(pump['serial_number'].toString(), style: TextStyle(color: Colors.black))),
                    DataCell(Text(pump['pump_name'], style: TextStyle(color: Colors.black))),
                    DataCell(Text(pump['address'], style: TextStyle(color: Colors.black))),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Edit ${pump['pump_name']}')),
                            );
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
                                  content: Text('Are you sure you want to delete ${pump['pump_name']}?'),
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
                                        await _deletePetrolPump(pump['serial_number']);
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