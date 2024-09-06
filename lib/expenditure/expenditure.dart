import 'package:flutter/material.dart';
import 'ExpenditureDashboardScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'expenditure_master_screen.dart';

class ExpenditurePage extends StatefulWidget {
  @override
  _ExpenditurePageState createState() => _ExpenditurePageState();
}

class _ExpenditurePageState extends State<ExpenditurePage> {
  int _currentStep = 0;
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _staffNameController = TextEditingController();
  final TextEditingController _staffIdController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _paymentMode = 'Online';
  String? _selectedMonth;
  String? _selectedYear;
  List<String> _categories = [];

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> _years = List<String>.generate(10, (int index) {
    return (DateTime.now().year - index).toString();
  });

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> categories = json.decode(response.body);
        setState(() {
          _categories = categories.map((category) => category['item_description'].toString()).toList();
        });
      } else {
        print('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _staffNameController.dispose();
    _staffIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addExpenditure() async {
    final String description = _descriptionController.text;
    final String amount = _amountController.text;
    final String staffName = _staffNameController.text;
    final String staffId = _staffIdController.text;

    // Extract month name and year from the selected date
    final String month = _months[_selectedDate.month - 1];
    final String year = _selectedDate.year.toString();

    Map<String, dynamic> newExpenditure = {
      'category': _selectedCategory,
      'description': description,
      'amount': amount,
      'staffName': _selectedCategory == "Salary" ? staffName : '',
      'staffId': _selectedCategory == "Salary" ? staffId : '',
      'paymentMode': _paymentMode,
      'date': _selectedDate.toLocal().toString().split(' ')[0],
      'month': month,
      'year': year,
    };

    var response = await http.post(
      Uri.parse('http://localhost:3000/expenditures'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(newExpenditure),
    );

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ExpenditureDashboardScreen()),
      );
    } else {
      // Handle error
      print('Failed to add expenditure');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Expenditure Details (व्यय विवरण दर्ज करें)'),
        actions: [
          IconButton(
            icon: Icon(Icons.monetization_on_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpenditureMasterScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpenditureDashboardScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('expenditure.jpeg'), fit: BoxFit.cover),
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedYear,
                    decoration: InputDecoration(
                      labelText: 'Select Year (वर्ष चुनें)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    items: _years.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedYear = value;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    decoration: InputDecoration(
                      labelText: 'Select Month (महीना चुनिए)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    items: _months.map((String month) {
                      return DropdownMenuItem<String>(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  Stepper(
                    currentStep: _currentStep,
                    onStepTapped: (step) => setState(() => _currentStep = step),
                    onStepContinue: () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep += 1);
                      } else {
                        _addExpenditure();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep -= 1);
                      }
                    },
                    steps: [
                      Step(
                        title: Text('Select Category (श्रेणी चुनना)', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: Column(
                          children: [
                            if (_categories.isNotEmpty) ..._categories.map((category) {
                              return ListTile(
                                title: Text(category),
                                leading: Radio<String>(
                                  value: category,
                                  groupValue: _selectedCategory,
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                ),
                              );
                            }).toList() else Center(child: CircularProgressIndicator()),
                          ],
                        ),
                        isActive: _currentStep >= 0,
                      ),
                      Step(
                        title: Text('Enter Details (विवरण दर्ज करें)', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: Column(
                          children: [
                            if (_selectedCategory == "Salary") ...[
                              SizedBox(height: 16.0),
                              TextField(
                                controller: _staffNameController,
                                decoration: InputDecoration(
                                  labelText: 'Staff Name (स्टाफ का नाम)',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              TextField(
                                controller: _staffIdController,
                                decoration: InputDecoration(
                                  labelText: 'Staff ID (स्टाफ आईडी)',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              TextField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description (विवरण)',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16.0),
                            ] else ...[
                              TextField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Description (विवरण)',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 16.0),
                            ],
                            TextField(
                              controller: _amountController,
                              decoration: InputDecoration(
                                labelText: 'Amount (रकम)',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 16.0),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'Payment Mode (भुगतान का प्रकार)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text('Online (ऑनलाइन)'),
                              leading: Radio<String>(
                                value: 'Online',
                                groupValue: _paymentMode,
                                onChanged: (String? value) {
                                  setState(() {
                                    _paymentMode = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text('Cash (नकद)'),
                              leading: Radio<String>(
                                value: 'Cash',
                                groupValue: _paymentMode,
                                onChanged: (String? value) {
                                  setState(() {
                                    _paymentMode = value!;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: const Text('Cheque (चेक)'),
                              leading: Radio<String>(
                                value: 'Cheque',
                                groupValue: _paymentMode,
                                onChanged: (String? value) {
                                  setState(() {
                                    _paymentMode = value!;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                'Select Date (तारीख़ चुनें)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _selectDate(context),
                              child: Text(
                                'Select Date (तारीख़ चुनें)',
                                style: TextStyle(color: Colors.teal),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              'Selected Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        isActive: _currentStep >= 1,
                      ),
                      Step(
                        title: Text('Review & Submit (समीक्षा करें और सबमिट करें)', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category (श्रेणी): ${_selectedCategory ?? 'Not selected'}',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Description (विवरण): ${_descriptionController.text}',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Amount (रकम): ${_amountController.text}',
                              style: TextStyle(color: Colors.white),
                            ),
                            if (_selectedCategory == "Salary") ...[
                              SizedBox(height: 8.0),
                              Text(
                                'Staff Name (स्टाफ का नाम): ${_staffNameController.text}',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Staff ID (स्टाफ आईडी): ${_staffIdController.text}',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 8.0),
                            ],
                            SizedBox(height: 8.0),
                            Text(
                              'Payment Mode (भुगतान का प्रकार): $_paymentMode',
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Date (तिथि): ${_selectedDate.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        isActive: _currentStep >= 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
