import 'package:flutter/material.dart';
import 'package:school_management/Transport/petrol_pump_master_screen.dart';
import 'transportrequestform.dart';
import 'transport_request_dashboard.dart';
import 'api_service.dart';
import 'route_details_screen.dart';
import 'vehicle_insurance_screen.dart';
import 'student_transport_screen.dart';
import 'fuel_filling.dart';
import 'vehicle_maintenance.dart';
import 'bus_stop.dart';
import 'vehicle_check_list.dart';
import 'vendor_master.dart';

class TransportScreen extends StatefulWidget {
  @override
  _TransportScreenState createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Management'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Transport Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.directions_bus),
              title: Text('Request For Transport'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransportRequestForm()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_bus),
              title: Text('Student Transport Request Status'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransportRequestForm()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bus_alert_rounded),
              title: Text('Vehicle Daily Meter Reading'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FuelFillingScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bus_alert_rounded),
              title: Text('Vehicle Fuelling Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FuelFillingScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bus_alert_rounded),
              title: Text('Vehicle Maintenance List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VehicleMaintenanceScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bus_alert_rounded),
              title: Text('Vehicle Check List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VehicleChecklistScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bus_alert_rounded),
              title: Text('Vehicle Insurance Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VehicleInsuranceScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bus_alert_rounded),
              title: Text('Assign Transport to Student'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentTransportScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_road_outlined),
              title: Text('Route Master'),
              onTap: () async {
                Navigator.pop(context);

                try {
                  final routes = await ApiService.fetchRoutes();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetailsScreen(routes: routes),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to load routes'),
                  ));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.man),
              title: Text('Petrol Pump Master'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetrolPumpMasterScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bus_alert_rounded),
              title: Text('Vehicle Master'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Add Vehicle Report Clicked'),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.man),
              title: Text('Vendor Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VendorMasterScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_bus_outlined),
              title: Text('Bus Stop List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusStopMasterScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('transport.jpeg'), // Replace with your actual image asset path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Text(
            '',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}