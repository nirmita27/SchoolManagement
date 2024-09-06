import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class AdminFeeManagementPage extends StatefulWidget {
  @override
  _AdminFeeManagementPageState createState() => _AdminFeeManagementPageState();
}

class _AdminFeeManagementPageState extends State<AdminFeeManagementPage> {
  final _formKey = GlobalKey<FormState>();

  final _classController = TextEditingController();
  final _quarterController = TextEditingController();
  final _financialYearController = TextEditingController();
  final _tuitionFeeController = TextEditingController();
  final _examFeeController = TextEditingController();
  final _sportsFeeController = TextEditingController();
  final _electricityFeeController = TextEditingController();
  final _transportWithBusFeeController = TextEditingController();
  final _transportWithoutBusFeeController = TextEditingController();

  bool _isLoading = false;
  List<dynamic> _feeDetails = [];
  String? _selectedClass;
  String? _selectedQuarter;
  String? _selectedFinancialYear;

  @override
  void initState() {
    super.initState();
    _fetchFeeDetails();
  }

  Future<void> _fetchFeeDetails() async {
    final url = Uri.parse('http://localhost:3000/fees');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _feeDetails = data;
        });
      } else {
        print('Failed to load fee details with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        _showDialog('Error', 'Failed to load fee details. Please try again.');
      }
    } catch (error) {
      print('Error fetching fee details: $error');
      _showDialog('Error', 'Failed to fetch fee details. Please try again.');
    }
  }

  Future<void> _submitFeeDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:3000/fees');
    final body = json.encode({
      'class': _classController.text,
      'quarter': _quarterController.text,
      'financialYear': _financialYearController.text,
      'tuitionFee': double.parse(_tuitionFeeController.text),
      'examFee': double.parse(_examFeeController.text),
      'sportsFee': double.parse(_sportsFeeController.text),
      'electricityFee': double.parse(_electricityFeeController.text),
      'transportWithBusFee': double.parse(_transportWithBusFeeController.text),
      'transportWithoutBusFee': double.parse(_transportWithoutBusFeeController.text),
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        _showDialog('Success', 'Fee details added successfully.');
        _fetchFeeDetails(); // Refresh the fee details list
      } else {
        print('Failed to add fee details with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        _showDialog('Error', 'Failed to add fee details. Please try again.');
      }
    } catch (error) {
      print('Error adding fee details: $error');
      _showDialog('Error', 'An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showAddFeeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Fee Details'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Class', _classController),
                _buildTextField('Quarter', _quarterController),
                _buildTextField('Financial Year', _financialYearController),
                _buildTextField('Tuition Fee', _tuitionFeeController, isNumeric: true),
                _buildTextField('Exam Fee', _examFeeController, isNumeric: true),
                _buildTextField('Sports Fee', _sportsFeeController, isNumeric: true),
                _buildTextField('Electricity Fee', _electricityFeeController, isNumeric: true),
                _buildTextField('Transport With Bus Fee', _transportWithBusFeeController, isNumeric: true),
                _buildTextField('Transport Without Bus Fee', _transportWithoutBusFeeController, isNumeric: true),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text('Submit'),
            onPressed: () {
              _submitFeeDetails();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartData(Map<String, dynamic> fee) {
    List<PieChartSectionData> sections = [];
    sections.add(PieChartSectionData(
      value: double.parse(fee['tuition_fee'].toString()),
      color: Colors.blue,
      titleStyle: TextStyle(color: Colors.white, fontSize: 12),
    ));
    sections.add(PieChartSectionData(
      value: double.parse(fee['exam_fee'].toString()),
      color: Colors.green,
      titleStyle: TextStyle(color: Colors.white, fontSize: 12),
    ));
    sections.add(PieChartSectionData(
      value: double.parse(fee['sports_fee'].toString()),
      color: Colors.orange,
      titleStyle: TextStyle(color: Colors.white, fontSize: 12),
    ));
    sections.add(PieChartSectionData(
      value: double.parse(fee['electricity_fee'].toString()),
      color: Colors.red,
      titleStyle: TextStyle(color: Colors.white, fontSize: 12),
    ));
    if (fee['transport_with_bus_fee'] != null) {
      sections.add(PieChartSectionData(
        value: double.parse(fee['transport_with_bus_fee'].toString()),
        color: Colors.purple,
        titleStyle: TextStyle(color: Colors.white, fontSize: 12),
      ));
    }
    if (fee['transport_without_bus_fee'] != null) {
      sections.add(PieChartSectionData(
        value: double.parse(fee['transport_without_bus_fee'].toString()),
        color: Colors.brown,
        titleStyle: TextStyle(color: Colors.white, fontSize: 12),
      ));
    }
    return sections;
  }

  Widget _buildIndicators(Map<String, dynamic> fee) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIndicator('Tuition', Colors.blue),
        _buildIndicator('Exam', Colors.green),
        _buildIndicator('Sports', Colors.orange),
        _buildIndicator('Electricity', Colors.red),
        if (fee['transport_with_bus_fee'] != null)
          _buildIndicator('Bus', Colors.purple),
        if (fee['transport_without_bus_fee'] != null)
          _buildIndicator('No Bus', Colors.brown),
      ],
    );
  }

  Widget _buildIndicator(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> classes = _feeDetails.map((fee) => fee['class'].toString()).toSet().toList();
    List<String> quarters = _feeDetails.map((fee) => fee['quarter'].toString()).toSet().toList();
    List<String> financialYears = _feeDetails.map((fee) => fee['financial_year'].toString()).toSet().toList();

    Map<String, dynamic>? selectedFee = _feeDetails.firstWhere(
          (fee) => fee['class'] == _selectedClass && fee['quarter'] == _selectedQuarter && fee['financial_year'] == _selectedFinancialYear,
      orElse: () => null,
    );

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('finance.jpeg'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fee Management'),
          backgroundColor: Colors.blueAccent,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedClass,
                      hint: Text('Select Class'),
                      items: classes.map((className) {
                        return DropdownMenuItem<String>(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedClass = value;
                          _selectedQuarter = null; // Reset quarter when class changes
                          _selectedFinancialYear = null; // Reset financial year when class changes
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedQuarter,
                      hint: Text('Select Quarter'),
                      items: quarters.map((quarterName) {
                        return DropdownMenuItem<String>(
                          value: quarterName,
                          child: Text(quarterName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedQuarter = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedFinancialYear,
                      hint: Text('Select Financial Year'),
                      items: financialYears.map((year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFinancialYear = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(height: 20),
                    selectedFee != null
                        ? Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Class: ${selectedFee['class']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Quarter: ${selectedFee['quarter']}', style: TextStyle(fontSize: 16)),
                            Text('Financial Year: ${selectedFee['financial_year']}', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 10),
                            Text('Fees Breakdown:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: Container(
                            //         height: 300,
                            //         child: PieChart(
                            //           PieChartData(
                            //             sections: _buildPieChartData(selectedFee),
                            //             sectionsSpace: 2,
                            //             centerSpaceRadius: 40,
                            //             borderData: FlBorderData(show: false),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //     _buildIndicators(selectedFee),
                            //   ],
                            // ),
                            // SizedBox(height: 10),
                            Text('Tuition Fee: ₹${selectedFee['tuition_fee']}', style: TextStyle(fontSize: 16)),
                            Text('Exam Fee: ₹${selectedFee['exam_fee']}', style: TextStyle(fontSize: 16)),
                            Text('Sports Fee: ₹${selectedFee['sports_fee']}', style: TextStyle(fontSize: 16)),
                            Text('Electricity Fee: ₹${selectedFee['electricity_fee']}', style: TextStyle(fontSize: 16)),
                            Text('Transport with Bus Fee: ₹${selectedFee['transport_with_bus_fee'] ?? '0'}', style: TextStyle(fontSize: 16)),
                            Text('Transport without Bus Fee: ₹${selectedFee['transport_without_bus_fee'] ?? '0'}', style: TextStyle(fontSize: 16)),
                            Text('Total Fee: ₹${selectedFee['total_fee']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                        : Center(
                      child: Text(
                        'Please select a class, quarter, and financial year to view details.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddFeeDialog,
          child: Icon(Icons.add),
          backgroundColor: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (isNumeric && double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
