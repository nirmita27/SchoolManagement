import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeeMasterScreen extends StatefulWidget {
  final String schoolRange;

  FeeMasterScreen({required this.schoolRange});

  @override
  _FeeMasterScreenState createState() => _FeeMasterScreenState();
}

class _FeeMasterScreenState extends State<FeeMasterScreen> {
  List<dynamic> _feeMasters = [];
  bool _isLoading = true;
  double _totalFees = 0.0;

  String _selectedClass = '6';
  String _selectedStudentType = 'Old';
  String _selectedFinancialYear = '2024';

  List<String> _classOptions() {
    return widget.schoolRange == '6-8'
        ? ['6', '7', '8']
        : ['9', '10', '11', '12'];
  }

  final List<String> _studentTypes = ['New', 'Old'];
  final List<String> _financialYears = List<String>.generate(20, (int index) {
    return (DateTime.now().year + index).toString();
  });

  @override
  void initState() {
    super.initState();
    _fetchFeeMasters();
  }

  void _fetchFeeMasters() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/fees-master/$_selectedClass/$_selectedFinancialYear/$_selectedStudentType'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        double total = 0.0;
        for (var fee in data) {
          total += double.parse(fee['amount'].toString());
        }
        setState(() {
          _feeMasters = data;
          _totalFees = total;
          _isLoading = false;
        });
      } else {
        print('Failed to load fee masters');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching fee masters: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editFeeMaster(int index) async {
    final feeMaster = _feeMasters[index];
    final newAmount = await _showEditDialog(
        context, feeMaster['fee_name'], double.parse(feeMaster['amount'].toString()));
    if (newAmount != null) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/fees-master'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'classId': _selectedClass,
            'studentType': _selectedStudentType,
            'financialYear': _selectedFinancialYear,
            'feeName': feeMaster['fee_name'],
            'amount': newAmount,
          }),
        );
        if (response.statusCode == 201) {
          setState(() {
            _feeMasters[index]['amount'] = newAmount;
            _totalFees = _feeMasters.fold(
                0.0, (sum, fee) => sum + double.parse(fee['amount'].toString()));
          });
        } else {
          print('Failed to update fee master');
        }
      } catch (e) {
        print('Error updating fee master: $e');
      }
    }
  }

  void _deleteFeeMaster(int id, int index) async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:3000/fees-master/$id'));
      if (response.statusCode == 200) {
        setState(() {
          _feeMasters.removeAt(index);
          _totalFees = _feeMasters.fold(
              0.0, (sum, fee) => sum + double.parse(fee['amount'].toString()));
        });
      } else {
        print('Failed to delete fee master');
      }
    } catch (e) {
      print('Error deleting fee master: $e');
    }
  }

  Future<void> _createNewFeeMaster() async {
    final feeData = await _showCreateDialog(context);
    if (feeData != null) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/fees-master'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(feeData),
        );
        if (response.statusCode == 201) {
          setState(() {
            _feeMasters.add(feeData);
            _totalFees += feeData['amount'];
          });
        } else {
          print('Failed to create new fee master');
        }
      } catch (e) {
        print('Error creating new fee master: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> _showCreateDialog(BuildContext context) {
    TextEditingController feeNameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    String selectedClass = _selectedClass;
    String selectedStudentType = _selectedStudentType;
    String selectedFinancialYear = _selectedFinancialYear;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create New Fee (नया शुल्क बनाएं)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: feeNameController,
                decoration: InputDecoration(labelText: 'Fee Name (शुल्क नाम)'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount (मात्रा)'),
              ),
              SizedBox(height: 8),
              buildDropdown(
                value: selectedClass,
                items: _classOptions(),
                onChanged: (String? newValue) {
                  selectedClass = newValue!;
                },
                label: 'Select Class (कक्षा का चयन करें)',
              ),
              SizedBox(height: 8),
              buildDropdown(
                value: selectedStudentType,
                items: _studentTypes,
                onChanged: (String? newValue) {
                  selectedStudentType = newValue!;
                },
                label: 'Select Student Type (छात्र प्रकार का चयन करें)',
              ),
              SizedBox(height: 8),
              buildDropdown(
                value: selectedFinancialYear,
                items: _financialYears,
                onChanged: (String? newValue) {
                  selectedFinancialYear = newValue!;
                },
                label: 'Select Financial Year (वित्तीय वर्ष चुनें)',
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final feeName = feeNameController.text;
                final amount = double.tryParse(amountController.text);
                if (feeName.isNotEmpty && amount != null) {
                  Navigator.of(context).pop({
                    'classId': selectedClass,
                    'studentType': selectedStudentType,
                    'financialYear': selectedFinancialYear,
                    'feeName': feeName,
                    'amount': amount,
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<double?> _showEditDialog(
      BuildContext context, String feeName, double currentAmount) {
    TextEditingController controller =
    TextEditingController(text: currentAmount.toString());
    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $feeName'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Amount (मात्रा)'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final newAmount = double.tryParse(controller.text);
                if (newAmount != null) {
                  Navigator.of(context).pop(newAmount);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fee Master (फीस मास्टर)'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createNewFeeMaster,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDropdown(
                  value: _selectedClass,
                  items: _classOptions(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedClass = newValue!;
                      _fetchFeeMasters();
                    });
                  },
                  label: 'Select Class (कक्षा का चयन करें)',
                ),
                SizedBox(height: 8),
                buildDropdown(
                  value: _selectedStudentType,
                  items: _studentTypes,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStudentType = newValue!;
                      _fetchFeeMasters();
                    });
                  },
                  label: 'Select Student Type (छात्र प्रकार का चयन करें)',
                ),
                SizedBox(height: 8),
                buildDropdown(
                  value: _selectedFinancialYear,
                  items: _financialYears,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFinancialYear = newValue!;
                      _fetchFeeMasters();
                    });
                  },
                  label: 'Select Financial Year (वित्तीय वर्ष चुनें)',
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _feeMasters.length,
                    itemBuilder: (context, index) {
                      final feeMaster = _feeMasters[index];
                      return ListTile(
                        title: Text(feeMaster['fee_name']),
                        subtitle: Text('₹${feeMaster['amount']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editFeeMaster(index);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteFeeMaster(feeMaster['id'], index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Fees: ₹${_totalFees.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        contentPadding:
        EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
