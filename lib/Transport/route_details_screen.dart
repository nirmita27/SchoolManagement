import 'package:flutter/material.dart';
import 'api_service.dart';

class RouteDetailsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> routes;

  RouteDetailsScreen({required this.routes});

  @override
  _RouteDetailsScreenState createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  List<Map<String, dynamic>> _routes = [];

  @override
  void initState() {
    super.initState();
    _routes = widget.routes;
  }

  Future<void> _deleteRoute(int routeId) async {
    try {
      await ApiService.deleteRoute(routeId);

      setState(() {
        _routes.removeWhere((route) => route['route_id'] == routeId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Route deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete route: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Details'),
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
                DataColumn(label: Text('Route Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Start Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('End Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Stops', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              ],
              rows: _routes.map((route) {
                return DataRow(
                  cells: [
                    DataCell(Text(route['route_name'], style: TextStyle(color: Colors.black))),
                    DataCell(Text(route['start_location'], style: TextStyle(color: Colors.black))),
                    DataCell(Text(route['end_location'], style: TextStyle(color: Colors.black))),
                    DataCell(Container(
                      width: 150, // adjust width as needed
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: (route['stops'] as List<dynamic>)
                              .map((stop) => Text(stop.toString(), style: TextStyle(color: Colors.blue)))
                              .toList(),
                        ),
                      ),
                    )),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Edit ${route['route_name']}')),
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
                                  content: Text('Are you sure you want to delete ${route['route_name']}?'),
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
                                        await _deleteRoute(route['route_id']);
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