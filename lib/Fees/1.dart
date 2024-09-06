import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentFeesForm extends StatefulWidget {
  @override
  _StudentFeesFormState createState() => _StudentFeesFormState();
}

class _StudentFeesFormState extends State<StudentFeesForm> {
  int _currentStep = 0;
  String _selectedClass = 'Class 6';
  List<String> _students = ['Student 1', 'Student 2', 'Student 3'];
  String _selectedStudent = 'Student 1';
  String _selectedPaymentMode = 'Online';
  double _feesAmount = 0.0;
  String _studentType = 'Old';
  String _submittedTo = 'Accountant';

  final Map<String, double> _newStudentFees68 = {
    'Development Fee': 100.0,
    'Annual Fees': 100.0,
    'Entry Form': 10.0,
    'National Festival': 50.0,
    'Other Fees': 60.0,
    'Introductory Letter': 30.0,
    'Monthly Fees': 300.0,
  };

  final Map<String, double> _oldStudentFees68 = {
    'Development Fee': 50.0,
    'Annual Fees': 100.0,
    'National Festival': 50.0,
    'Monthly Fees': 300.0,
  };

  final Map<String, double> _newStudentFees9 = {
    'Entry & Development Fees': 100.0,
    'Annual Fees': 100.0,
    'Entry Form': 10.0,
    'National Festival': 50.0,
    'Registration Fees': 120.0,
    'Fees': 40.0,
    'Introductory Letter': 30.0,
    'Monthly Fees': 350.0,
  };

  final Map<String, double> _oldStudentFees10 = {
    'Development Fee': 50.0,
    'Annual Fees': 100.0,
    'National Festival': 50.0,
    'Monthly Fees': 350.0,
    'Board Examination Fees': 600.0,
  };

  final Map<String, double> _newStudentFees10 = {
    'Entry & Development Fees': 100.0,
    'Annual Fees': 100.0,
    'Entry Form': 10.0,
    'National Festival': 50.0,
    'Monthly Fees': 350.0,
    'Board Examination Fees': 600.0,
    'Introductory Letter': 40.0,
  };

  final Map<String, double> _newStudentFees11 = {
    'Entry & Development Fees': 100.0,
    'Annual Fees': 100.0,
    'Entry Form': 10.0,
    'National Festival': 50.0,
    'Registration Fees': 120.0,
    'Other Fees': 40.0,
    'Introductory Letter': 30.0,
    'Monthly Fees': 400.0,
  };

  final Map<String, double> _oldStudentFees12 = {
    'Development Fee': 50.0,
    'Annual Fees': 100.0,
    'National Festival': 50.0,
    'Monthly Fees': 400.0,
    'Board Examination Fees': 700.0,
  };

  final Map<String, double> _newStudentFees12 = {
    'Entry Fees and Development Fee': 100.0,
    'Annual Fees': 100.0,
    'Entry Form' : 10.0,
    'National Festival': 50.0,
    'Monthly Fees': 400.0,
    'Board Examination Fees': 700.0,
    'Introductory Letter' : 40.0,
  };
  double get _totalNewFees68 =>
      _newStudentFees68.values.reduce((a, b) => a + b);
  double get _totalOldFees68 =>
      _oldStudentFees68.values.reduce((a, b) => a + b);
  double get _totalNewFees9 => _newStudentFees9.values.reduce((a, b) => a + b);
  double get _totalOldFees10 =>
      _oldStudentFees10.values.reduce((a, b) => a + b);

  void _submitFees() {
    _generateReceipt();
  }

  void _generateReceipt() {
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
                  Text(
                    'Receipt',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  buildReceiptDetail('Class', _selectedClass),
                  buildReceiptDetail('Student Type', _studentType),
                  buildReceiptDetail('Student', _selectedStudent),
                  buildReceiptDetail('Payment Mode', _selectedPaymentMode),
                  buildReceiptDetail('Submitted To', _submittedTo),
                  if (_isEligibleForFeeTable) ...[
                    SizedBox(height: 16),
                    Text(
                      'Fees Structure:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    _buildFeesTable(),
                  ],
                  buildReceiptDetail(
                    'Fees Amount',
                    '${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(_feesAmount)}',
                  ),
                  buildReceiptDetail(
                    'Date',
                    DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                  SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
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

  bool get _isEligibleForFeeTable =>
      (_selectedClass == 'Class 6' ||
          _selectedClass == 'Class 7' ||
          _selectedClass == 'Class 8' ||
          _selectedClass == 'Class 9' ||
          _selectedClass == 'Class 10');

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Fees Submission'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        constraints: BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.white],
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
                Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    setState(() {
                      if (_currentStep < 4) {
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
                      title: Text('Select Class'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDropdown(
                            value: _selectedClass,
                            items: <String>[
                              'Class 6',
                              'Class 7',
                              'Class 8',
                              'Class 9',
                              'Class 10',
                              'Class 11',
                              'Class 12'
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedClass = newValue!;
                                _students = _getStudentsForClass(newValue);
                                _selectedStudent = _students.first;
                              });
                            },
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: Text('Is Student New or Old?'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: const Text('Old'),
                            leading: Radio<String>(
                              value: 'Old',
                              groupValue: _studentType,
                              onChanged: (String? value) {
                                setState(() {
                                  _studentType = value!;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('New'),
                            leading: Radio<String>(
                              value: 'New',
                              groupValue: _studentType,
                              onChanged: (String? value) {
                                setState(() {
                                  _studentType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                    ),
                    Step(
                      title: Text('Select Student'),
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
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 2,
                    ),
                    Step(
                      title: Text('Select Payment Mode'),
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
                                  child: Text('Online'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedPaymentMode == 'Online'
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedPaymentMode = 'Cash';
                                    });
                                  },
                                  child: Text('Cash'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedPaymentMode == 'Cash'
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 3,
                    ),
                    Step(
                      title: Text('Fees Details'),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFeesTable(),
                          SizedBox(height: 16),
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                _feesAmount = double.tryParse(value) ?? 0.0;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Enter Fees Amount',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 4,
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

  Widget _buildFeesTable() {
    final fees = _selectedClass == 'Class 9' && _studentType == 'New'
        ? _newStudentFees9
        : _selectedClass == 'Class 6' ||
        _selectedClass == 'Class 7' ||
        _selectedClass == 'Class 8'
        ? _studentType == 'New'
        ? _newStudentFees68
        : _oldStudentFees68
        : _selectedClass == 'Class 10' && _studentType == 'Old'
        ? _oldStudentFees10
        : {};

    final totalFees = _selectedClass == 'Class 9' && _studentType == 'New'
        ? _totalNewFees9
        : _selectedClass == 'Class 6' ||
        _selectedClass == 'Class 7' ||
        _selectedClass == 'Class 8'
        ? _studentType == 'New'
        ? _totalNewFees68
        : _totalOldFees68
        : _selectedClass == 'Class 10' && _studentType == 'Old'
        ? _totalOldFees10
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Table(
        border: TableBorder.all(color: Colors.blueGrey),
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
            decoration: BoxDecoration(color: Colors.blueGrey.shade100),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '₹${totalFees.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
      style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade900),
      underline: Container(
        height: 2,
        color: Colors.blueGrey.shade900,
      ),
    );
  }

  List<String> _getStudentsForClass(String? className) {
    switch (className) {
      case 'Class 6':
        return ['Student 1', 'Student 2', 'Student 3'];
      case 'Class 7':
        return ['Student 4', 'Student 5', 'Student 6'];
      case 'Class 8':
        return ['Student 7', 'Student 8', 'Student 9'];
      case 'Class 9':
        return ['Student 10', 'Student 11', 'Student 12'];
      case 'Class 10':
        return ['Student 13', 'Student 14', 'Student 15'];
      case 'Class 11':
        return ['Student 16', 'Student 17', 'Student 18'];
      case 'Class 12':
        return ['Student 19', 'Student 20', 'Student 21'];
      default:
        return [];
    }
  }
}