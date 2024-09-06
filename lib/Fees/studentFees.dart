import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'FeesDashboardScreen.dart';
import 'feeMasterScreen.dart';

class StudentFeesForm extends StatefulWidget {
  final String schoolRange;

  StudentFeesForm({required this.schoolRange});

  @override
  _StudentFeesFormState createState() => _StudentFeesFormState();
}

class _StudentFeesFormState extends State<StudentFeesForm> {
  int _currentStep = 0;
  String _selectedClass = '6';
  String _studentType = 'Old';
  List<String> _students = [];
  String? _selectedStudent;
  String _selectedPaymentMode = 'Online';
  String _submittedTo = 'Teacher';
  double _feesAmount = 0.0;
  String _parentName = '';
  String _contactNumber = '';
  String _address = '';
  String _selectedYear = DateTime.now().year.toString();
  String _selectedMonth = DateFormat.MMMM().format(DateTime.now());
  double _totalFees = 0.0;
  Map<String, double> _fees = {};

  final List<String> _years = List<String>.generate(10, (int index) {
    return (DateTime.now().year - index).toString();
  });

  final List<String> _months = List<String>.generate(12, (int index) {
    return DateFormat.MMMM().format(DateTime(0, index + 1));
  });

  @override
  void initState() {
    super.initState();
    _fetchStudentsForClass(_selectedClass);
  }

  void _fetchStudentsForClass(String className) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/students/$className'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _students = data.map((student) => '${student['first_name']} ${student['last_name']}').toList();
          if (_students.isNotEmpty) {
            _selectedStudent = _students.first;
          } else {
            _selectedStudent = null;
          }
        });
      } else {
        setState(() {
          _students = [];
          _selectedStudent = null;
        });
        print('No students found for the specified class.');
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  void _fetchFees(String className, String studentType) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/fees-master/$className/${_selectedYear}/$studentType'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _fees = {for (var item in data) item['fee_name']: double.parse(item['amount'].toString())};
          _totalFees = _fees.values.fold(0.0, (sum, item) => sum + item);
        });
      } else {
        setState(() {
          _fees = {};
          _totalFees = 0.0;
        });
        print('No fees found for the specified class and student type.');
      }
    } catch (e) {
      print('Error fetching fees: $e');
    }
  }

  void _submitFees() async {
    double totalFee = _calculateTotalFee();
    double pendingFee = totalFee - _feesAmount;

    final feesData = {
      'class': _selectedClass,
      'student_name': _selectedStudent,
      'student_type': _studentType,
      'parent_name': _parentName,
      'contact_number': _contactNumber,
      'address': _address,
      'payment_mode': _selectedPaymentMode,
      'submitted_to': _submittedTo,
      'fees_amount': _feesAmount,
      'year': _selectedYear,
      'month': _selectedMonth,
      'total_fee': totalFee,
      'pending_fee': pendingFee,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/fees-record'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(feesData),
      );

      if (response.statusCode == 201) {
        _generateReceipt();
      } else {
        print('Failed to submit fees');
      }
    } catch (e) {
      print('Error submitting fees: $e');
    }
  }

  double _calculateTotalFee() {
    return _totalFees;
  }

  void _generateReceipt() {
    double totalFee = _calculateTotalFee();
    double pendingFee = totalFee - _feesAmount;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Receipt (रसीद)',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16),
                  buildReceiptDetail('Class (कक्षा)', _selectedClass),
                  buildReceiptDetail('Student Type (छात्र प्रकार)', _studentType),
                  buildReceiptDetail('Student (विद्यार्थी)', _selectedStudent ?? 'N/A'),
                  buildReceiptDetail('Payment Mode (भुगतान का प्रकार)', _selectedPaymentMode),
                  buildReceiptDetail('Submitted To (को प्रस्तुत)', _submittedTo),
                  SizedBox(height: 16),
                  Text(
                    'Fees Structure (फीस संरचना):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildFeesTable(),
                  buildReceiptDetail(
                    'Total Fees Amount (कुल शुल्क राशि)',
                    '${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(totalFee)}',
                  ),
                  buildReceiptDetail(
                    'Paid Fees Amount (भुगतान की गई फीस राशि)',
                    '${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_feesAmount)}',
                  ),
                  buildReceiptDetail(
                    'Pending Fees Amount (लंबित शुल्क राशि)',
                    '${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(pendingFee)}',
                  ),
                  buildReceiptDetail(
                    'Date (तारीख)',
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => FeesDashboardScreen(schoolRange: widget.schoolRange,)),
                        );
                      },
                      child: Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildReceiptDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalFee = _calculateTotalFee();

    return Scaffold(
      appBar: AppBar(
        title: Text('Student Fees Submission (छात्र शुल्क जमा करना)'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.dashboard, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeesDashboardScreen(schoolRange: widget.schoolRange,)),
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeeMasterScreen(schoolRange: widget.schoolRange,)),
              );
            },
            icon: Icon(Icons.attach_money),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildDropdown(
                  value: _selectedYear,
                  items: _years,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedYear = newValue!;
                    });
                  },
                  label: 'Select Year (वर्ष चुनें)',
                ),
                SizedBox(height: 8,),
                buildDropdown(
                  value: _selectedMonth,
                  items: _months,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMonth = newValue!;
                    });
                  },
                  label: 'Select Month (महीना चुनिए)',
                ),
                Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    setState(() {
                      if (_currentStep < 6) {
                        _currentStep += 1;
                      } else {
                        _submitFees();
                      }
                    });
                  },
                  onStepCancel: () {
                    setState(() {
                      if (_currentStep > 0) {
                        _currentStep -= 1;
                      }
                    });
                  },
                  steps: [
                    Step(
                      title: Text('Select Class (कक्षा का चयन करें)'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDropdown(
                            value: _selectedClass,
                            items: widget.schoolRange == '6-8'
                                ? <String>['6', '7', '8']
                                : <String>['9', '10', '11', '12'],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedClass = newValue!;
                                _fetchStudentsForClass(newValue);
                                _fetchFees(newValue, _studentType);
                              });
                            },
                            label: 'Select Class (कक्षा का चयन करें)',
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: Text('Select Student Type (छात्र प्रकार का चयन करें)'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: const Text('Old (पुराना)'),
                            leading: Radio<String>(
                              value: 'Old',
                              groupValue: _studentType,
                              onChanged: (String? value) {
                                setState(() {
                                  _studentType = value!;
                                  _fetchFees(_selectedClass, value);
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('New (नया)'),
                            leading: Radio<String>(
                              value: 'New',
                              groupValue: _studentType,
                              onChanged: (String? value) {
                                setState(() {
                                  _studentType = value!;
                                  _fetchFees(_selectedClass, value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                    ),
                    Step(
                      title: Text('Select Student (छात्र का चयन करें)'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDropdown(
                            value: _selectedStudent,
                            items: _students,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStudent = newValue!;
                              });
                            },
                            label: 'Select Student (छात्र का चयन करें)',
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 2,
                    ),
                    Step(
                      title: Text('Parent Details (जनक विवरण)'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildTextFormField(
                            label: 'Parent Name (अभिभावक का नाम)',
                            onChanged: (value) {
                              setState(() {
                                _parentName = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          buildTextFormField(
                            label: 'Contact Number (संपर्क संख्या)',
                            onChanged: (value) {
                              setState(() {
                                _contactNumber = value;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          buildTextFormField(
                            label: 'Address (पता)',
                            onChanged: (value) {
                              setState(() {
                                _address = value;
                              });
                            },
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 3,
                    ),
                    Step(
                      title: Text('Select Payment Mode (भुगतान मोड चुनें)'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedPaymentMode = 'Online';
                                    });
                                  },
                                  child: Text('Online (ऑनलाइन)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedPaymentMode == 'Online' ? Colors.teal : Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedPaymentMode = 'Cash';
                                    });
                                  },
                                  child: Text('Cash (नकद)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedPaymentMode == 'Cash' ? Colors.teal : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 4,
                    ),
                    Step(
                      title: Text('Submit To (इन्हें प्रस्तुत करें)'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDropdown(
                            value: _submittedTo,
                            items: <String>['Teacher', 'Accountant'],
                            onChanged: (String? newValue) {
                              setState(() {
                                _submittedTo = newValue!;
                              });
                            },
                            label: 'Submit To (इन्हें प्रस्तुत करें)',
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 5,
                    ),
                    Step(
                      title: Text('Enter Fees Amount (फीस राशि दर्ज करें)'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _feesAmount = double.tryParse(value) ?? 0.0;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter fees amount (फीस राशि दर्ज करें)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Total Fees: ₹${_totalFees.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 6,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget buildTextFormField({
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildFeesTable() {
    final fees = _fees;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Table(
        border: TableBorder.all(color: Colors.teal),
        columnWidths: {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
        },
        children: [
          ...fees.entries.map(
                (entry) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(entry.key),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('₹${entry.value.toStringAsFixed(2)}'),
                ),
              ],
            ),
          ),
          TableRow(
            decoration: BoxDecoration(color: Colors.teal.shade100),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total (कुल)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '₹${_totalFees.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
