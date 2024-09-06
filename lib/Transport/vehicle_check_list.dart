import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleChecklistScreen extends StatefulWidget {
  @override
  _VehicleChecklistScreenState createState() => _VehicleChecklistScreenState();
}

class _VehicleChecklistScreenState extends State<VehicleChecklistScreen> {
  List<dynamic> vehicleChecklists = [];

  @override
  void initState() {
    super.initState();
    fetchVehicleChecklists();
  }

  Future<void> fetchVehicleChecklists() async {
    final response = await http.get(Uri.parse('http://localhost:3000/vehicle-checklist'));

    if (response.statusCode == 200) {
      setState(() {
        vehicleChecklists = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load vehicle checklists');
    }
  }

  Future<void> deleteVehicleChecklist(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/vehicle-checklist/$id'));

    if (response.statusCode == 200) {
      fetchVehicleChecklists();
    } else {
      throw Exception('Failed to delete vehicle checklist');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Checklist'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VehicleChecklistFormScreen()),
              ).then((value) => fetchVehicleChecklists());
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: vehicleChecklists.length,
        itemBuilder: (context, index) {
          final checklist = vehicleChecklists[index];
          return ListTile(
            title: Text('${checklist['date']} - ${checklist['vehicle_name']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VehicleChecklistFormScreen(checklist: checklist),
                      ),
                    ).then((value) => fetchVehicleChecklists());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteVehicleChecklist(checklist['id']);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VehicleChecklistFormScreen extends StatefulWidget {
  final dynamic checklist;

  VehicleChecklistFormScreen({this.checklist});

  @override
  _VehicleChecklistFormScreenState createState() => _VehicleChecklistFormScreenState();
}

class _VehicleChecklistFormScreenState extends State<VehicleChecklistFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _vehicleNameController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _drivingLicenseRenewalDateController = TextEditingController();
  final TextEditingController _vehicleRcController = TextEditingController();
  final TextEditingController _insuranceRenewalDateController = TextEditingController();
  final TextEditingController _pollutionRenewalDateController = TextEditingController();
  final TextEditingController _mvTaxDateController = TextEditingController();
  final TextEditingController _counterSignRenewalDateController = TextEditingController();
  final TextEditingController _passingRenewalDateController = TextEditingController();
  final TextEditingController _otherStateTaxRenewalDateController = TextEditingController();
  final TextEditingController _permitRenewalDateController = TextEditingController();
  final TextEditingController _dvrStatusController = TextEditingController();
  final TextEditingController _medicalBoxController = TextEditingController();
  final TextEditingController _camera1StatusController = TextEditingController();
  final TextEditingController _camera2StatusController = TextEditingController();
  final TextEditingController _camera3StatusController = TextEditingController();
  final TextEditingController _fireEquipmentController = TextEditingController();
  final TextEditingController _seatBeltController = TextEditingController();
  final TextEditingController _challanIfAnyController = TextEditingController();
  final TextEditingController _routeChartController = TextEditingController();
  final TextEditingController _reflectorStickerController = TextEditingController();
  final TextEditingController _seatCoverController = TextEditingController();
  final TextEditingController _acController = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  final TextEditingController _batchesWhistleController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _washingController = TextEditingController();
  final TextEditingController _todaysReadingController = TextEditingController();
  final TextEditingController _greasingController = TextEditingController();
  final TextEditingController _brakeCheckController = TextEditingController();
  final TextEditingController _wheelAlignmentController = TextEditingController();
  final TextEditingController _checkAllGlassesController = TextEditingController();
  final TextEditingController _lightsAndReflectorsController = TextEditingController();
  final TextEditingController _tyreController = TextEditingController();
  final TextEditingController _airCheckController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.checklist != null) {
      _dateController.text = widget.checklist['date'];
      _vehicleNameController.text = widget.checklist['vehicle_name'];
      _driverNameController.text = widget.checklist['driver_name'];
      _drivingLicenseRenewalDateController.text = widget.checklist['driving_license_renewal_date'];
      _vehicleRcController.text = widget.checklist['vehicle_rc'].toString();
      _insuranceRenewalDateController.text = widget.checklist['insurance_renewal_date'];
      _pollutionRenewalDateController.text = widget.checklist['pollution_renewal_date'];
      _mvTaxDateController.text = widget.checklist['mv_tax_date'];
      _counterSignRenewalDateController.text = widget.checklist['counter_sign_renewal_date'];
      _passingRenewalDateController.text = widget.checklist['passing_renewal_date'];
      _otherStateTaxRenewalDateController.text = widget.checklist['other_state_tax_renewal_date'];
      _permitRenewalDateController.text = widget.checklist['permit_renewal_date'];
      _dvrStatusController.text = widget.checklist['dvr_status'].toString();
      _medicalBoxController.text = widget.checklist['medical_box'].toString();
      _camera1StatusController.text = widget.checklist['camera1_status'].toString();
      _camera2StatusController.text = widget.checklist['camera2_status'].toString();
      _camera3StatusController.text = widget.checklist['camera3_status'].toString();
      _fireEquipmentController.text = widget.checklist['fire_equipment'].toString();
      _seatBeltController.text = widget.checklist['seat_belt'].toString();
      _challanIfAnyController.text = widget.checklist['challan_if_any'].toString();
      _routeChartController.text = widget.checklist['route_chart'].toString();
      _reflectorStickerController.text = widget.checklist['reflector_sticker'].toString();
      _seatCoverController.text = widget.checklist['seat_cover'].toString();
      _acController.text = widget.checklist['ac'].toString();
      _gpsController.text = widget.checklist['gps'].toString();
      _batchesWhistleController.text = widget.checklist['batches_whistle'].toString();
      _serviceController.text = widget.checklist['service'].toString();
      _washingController.text = widget.checklist['washing'].toString();
      _todaysReadingController.text = widget.checklist['todays_reading'].toString();
      _greasingController.text = widget.checklist['greasing'].toString();
      _brakeCheckController.text = widget.checklist['brake_check'].toString();
      _wheelAlignmentController.text = widget.checklist['wheel_alignment'].toString();
      _checkAllGlassesController.text = widget.checklist['check_all_glasses'].toString();
      _lightsAndReflectorsController.text = widget.checklist['lights_and_reflectors'].toString();
      _tyreController.text = widget.checklist['tyre'].toString();
      _airCheckController.text = widget.checklist['air_check'].toString();
    }
  }

  Future<void> submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final vehicleChecklist = {
      'date': _dateController.text,
      'vehicle_name': _vehicleNameController.text,
      'driver_name': _driverNameController.text,
      'driving_license_renewal_date': _drivingLicenseRenewalDateController.text,
      'vehicle_rc': _vehicleRcController.text.toLowerCase() == 'true',
      'insurance_renewal_date': _insuranceRenewalDateController.text,
      'pollution_renewal_date': _pollutionRenewalDateController.text,
      'mv_tax_date': _mvTaxDateController.text,
      'counter_sign_renewal_date': _counterSignRenewalDateController.text,
      'passing_renewal_date': _passingRenewalDateController.text,
      'other_state_tax_renewal_date': _otherStateTaxRenewalDateController.text,
      'permit_renewal_date': _permitRenewalDateController.text,
      'dvr_status': _dvrStatusController.text.toLowerCase() == 'true',
      'medical_box': _medicalBoxController.text.toLowerCase() == 'true',
      'camera1_status': _camera1StatusController.text.toLowerCase() == 'true',
      'camera2_status': _camera2StatusController.text.toLowerCase() == 'true',
      'camera3_status': _camera3StatusController.text.toLowerCase() == 'true',
      'fire_equipment': _fireEquipmentController.text.toLowerCase() == 'true',
      'seat_belt': _seatBeltController.text.toLowerCase() == 'true',
      'challan_if_any': _challanIfAnyController.text.toLowerCase() == 'true',
      'route_chart': _routeChartController.text.toLowerCase() == 'true',
      'reflector_sticker': _reflectorStickerController.text.toLowerCase() == 'true',
      'seat_cover': _seatCoverController.text.toLowerCase() == 'true',
      'ac': _acController.text.toLowerCase() == 'true',
      'gps': _gpsController.text.toLowerCase() == 'true',
      'batches_whistle': _batchesWhistleController.text.toLowerCase() == 'true',
      'service': _serviceController.text.toLowerCase() == 'true',
      'washing': _washingController.text.toLowerCase() == 'true',
      'todays_reading': int.parse(_todaysReadingController.text),
      'greasing': _greasingController.text.toLowerCase() == 'true',
      'brake_check': _brakeCheckController.text.toLowerCase() == 'true',
      'wheel_alignment': _wheelAlignmentController.text.toLowerCase() == 'true',
      'check_all_glasses': _checkAllGlassesController.text.toLowerCase() == 'true',
      'lights_and_reflectors': _lightsAndReflectorsController.text.toLowerCase() == 'true',
      'tyre': _tyreController.text.toLowerCase() == 'true',
      'air_check': _airCheckController.text.toLowerCase() == 'true',
    };

    if (widget.checklist != null) {
      // Update existing checklist
      final response = await http.put(
        Uri.parse('http://localhost:3000/vehicle-checklist/${widget.checklist['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vehicleChecklist),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to update vehicle checklist');
      }
    } else {
      // Add new checklist
      final response = await http.post(
        Uri.parse('http://localhost:3000/vehicle-checklist'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vehicleChecklist),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to add vehicle checklist');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.checklist != null ? 'Edit Vehicle Checklist' : 'Add Vehicle Checklist'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _vehicleNameController,
                decoration: InputDecoration(labelText: 'Vehicle Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a vehicle name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _driverNameController,
                decoration: InputDecoration(labelText: 'Driver Name'),
              ),
              TextFormField(
                controller: _drivingLicenseRenewalDateController,
                decoration: InputDecoration(labelText: 'Driving License Renewal Date'),
              ),
              TextFormField(
                controller: _vehicleRcController,
                decoration: InputDecoration(labelText: 'Vehicle RC (true/false)'),
              ),
              TextFormField(
                controller: _insuranceRenewalDateController,
                decoration: InputDecoration(labelText: 'Insurance Renewal Date'),
              ),
              TextFormField(
                controller: _pollutionRenewalDateController,
                decoration: InputDecoration(labelText: 'Pollution Renewal Date'),
              ),
              TextFormField(
                controller: _mvTaxDateController,
                decoration: InputDecoration(labelText: 'MV Tax Date'),
              ),
              TextFormField(
                controller: _counterSignRenewalDateController,
                decoration: InputDecoration(labelText: 'Counter Sign Renewal Date'),
              ),
              TextFormField(
                controller: _passingRenewalDateController,
                decoration: InputDecoration(labelText: 'Passing Renewal Date'),
              ),
              TextFormField(
                controller: _otherStateTaxRenewalDateController,
                decoration: InputDecoration(labelText: 'Other State Tax Renewal Date'),
              ),
              TextFormField(
                controller: _permitRenewalDateController,
                decoration: InputDecoration(labelText: 'Permit Renewal Date'),
              ),
              TextFormField(
                controller: _dvrStatusController,
                decoration: InputDecoration(labelText: 'DVR Status (true/false)'),
              ),
              TextFormField(
                controller: _medicalBoxController,
                decoration: InputDecoration(labelText: 'Medical Box (true/false)'),
              ),
              TextFormField(
                controller: _camera1StatusController,
                decoration: InputDecoration(labelText: 'Camera 1 Status (true/false)'),
              ),
              TextFormField(
                controller: _camera2StatusController,
                decoration: InputDecoration(labelText: 'Camera 2 Status (true/false)'),
              ),
              TextFormField(
                controller: _camera3StatusController,
                decoration: InputDecoration(labelText: 'Camera 3 Status (true/false)'),
              ),
              TextFormField(
                controller: _fireEquipmentController,
                decoration: InputDecoration(labelText: 'Fire Equipment (true/false)'),
              ),
              TextFormField(
                controller: _seatBeltController,
                decoration: InputDecoration(labelText: 'Seat Belt (true/false)'),
              ),
              TextFormField(
                controller: _challanIfAnyController,
                decoration: InputDecoration(labelText: 'Challan If Any (true/false)'),
              ),
              TextFormField(
                controller: _routeChartController,
                decoration: InputDecoration(labelText: 'Route Chart (true/false)'),
              ),
              TextFormField(
                controller: _reflectorStickerController,
                decoration: InputDecoration(labelText: 'Reflector/Sticker (true/false)'),
              ),
              TextFormField(
                controller: _seatCoverController,
                decoration: InputDecoration(labelText: 'Seat Cover (true/false)'),
              ),
              TextFormField(
                controller: _acController,
                decoration: InputDecoration(labelText: 'AC (true/false)'),
              ),
              TextFormField(
                controller: _gpsController,
                decoration: InputDecoration(labelText: 'GPS (true/false)'),
              ),
              TextFormField(
                controller: _batchesWhistleController,
                decoration: InputDecoration(labelText: 'Batches/Whistle (true/false)'),
              ),
              TextFormField(
                controller: _serviceController,
                decoration: InputDecoration(labelText: 'Service (true/false)'),
              ),
              TextFormField(
                controller: _washingController,
                decoration: InputDecoration(labelText: 'Washing (true/false)'),
              ),
              TextFormField(
                controller: _todaysReadingController,
                decoration: InputDecoration(labelText: 'Today\'s Reading'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _greasingController,
                decoration: InputDecoration(labelText: 'Greasing (true/false)'),
              ),
              TextFormField(
                controller: _brakeCheckController,
                decoration: InputDecoration(labelText: 'Brake Check (true/false)'),
              ),
              TextFormField(
                controller: _wheelAlignmentController,
                decoration: InputDecoration(labelText: 'Wheel Alignment (true/false)'),
              ),
              TextFormField(
                controller: _checkAllGlassesController,
                decoration: InputDecoration(labelText: 'Check All Glasses (true/false)'),
              ),
              TextFormField(
                controller: _lightsAndReflectorsController,
                decoration: InputDecoration(labelText: 'Lights and Reflectors (true/false)'),
              ),
              TextFormField(
                controller: _tyreController,
                decoration: InputDecoration(labelText: 'Tyre (true/false)'),
              ),
              TextFormField(
                controller: _airCheckController,
                decoration: InputDecoration(labelText: 'Air Check (true/false)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text(widget.checklist != null ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}