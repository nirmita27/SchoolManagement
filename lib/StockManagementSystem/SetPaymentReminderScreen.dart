import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SetPaymentReminderScreen extends StatefulWidget {
  @override
  _SetPaymentReminderScreenState createState() => _SetPaymentReminderScreenState();
}

class _SetPaymentReminderScreenState extends State<SetPaymentReminderScreen> {
  List<dynamic> reminders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReminders();
  }

  Future<void> _fetchReminders() async {
    final url = Uri.parse('http://localhost:3000/reminders');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          reminders = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reminders');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch reminders. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _showCreateReminderDialog() {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _dueDateController = TextEditingController();
    final _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Payment Reminder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _dueDateController,
                decoration: InputDecoration(labelText: 'Due Date'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
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
            child: Text('Add'),
            onPressed: () {
              final name = _nameController.text;
              final email = _emailController.text;
              final phone = _phoneController.text;
              final dueDate = _dueDateController.text;
              final amount = _amountController.text;

              if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty && dueDate.isNotEmpty && amount.isNotEmpty) {
                _createReminder(name, email, phone, dueDate, double.parse(amount));
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _createReminder(String name, String email, String phone, String dueDate, double amount) async {
    final url = Uri.parse('http://localhost:3000/reminders');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'due_date': dueDate,
          'amount': amount,
        }),
      );
      if (response.statusCode == 201) {
        _fetchReminders();
      } else {
        throw Exception('Failed to create reminder');
      }
    } catch (error) {
      _showErrorDialog('Failed to create reminder. Please try again.');
    }
  }

  void _showEditReminderDialog(int id, String name, String email, String phone, String dueDate, double amount) {
    final _nameController = TextEditingController(text: name);
    final _emailController = TextEditingController(text: email);
    final _phoneController = TextEditingController(text: phone);
    final _dueDateController = TextEditingController(text: dueDate);
    final _amountController = TextEditingController(text: amount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Payment Reminder'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _dueDateController,
                decoration: InputDecoration(labelText: 'Due Date'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
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
            child: Text('Save'),
            onPressed: () {
              final updatedName = _nameController.text;
              final updatedEmail = _emailController.text;
              final updatedPhone = _phoneController.text;
              final updatedDueDate = _dueDateController.text;
              final updatedAmount = double.parse(_amountController.text);

              if (updatedName.isNotEmpty && updatedEmail.isNotEmpty && updatedPhone.isNotEmpty && updatedDueDate.isNotEmpty && updatedAmount > 0) {
                _editReminder(id, updatedName, updatedEmail, updatedPhone, updatedDueDate, updatedAmount);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields with valid values.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _editReminder(int id, String name, String email, String phone, String dueDate, double amount) async {
    final url = Uri.parse('http://localhost:3000/reminders/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'due_date': dueDate,
          'amount': amount,
        }),
      );
      if (response.statusCode == 200) {
        _fetchReminders();
      } else {
        throw Exception('Failed to edit reminder');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit reminder. Please try again.');
    }
  }

  void _deleteReminder(int id) async {
    final url = Uri.parse('http://localhost:3000/reminders/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchReminders();
      } else {
        throw Exception('Failed to delete reminder');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete reminder. Please try again.');
    }
  }

  Widget _buildReminderTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Phone')),
        DataColumn(label: Text('Due Date')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Actions')),
      ],
      rows: reminders
          .asMap()
          .map((index, reminder) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(reminder['name'])),
          DataCell(Text(reminder['email'])),
          DataCell(Text(reminder['phone'])),
          DataCell(Text(reminder['due_date'])),
          DataCell(Text(reminder['amount'].toString())),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showEditReminderDialog(
                    reminder['id'],
                    reminder['name'],
                    reminder['email'],
                    reminder['phone'],
                    reminder['due_date'],
                    reminder['amount'],
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteReminder(reminder['id']);
                },
              ),
            ],
          )),
        ]),
      ))
          .values
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Reminders'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateReminderDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildReminderTable(),
        ),
      ),
    );
  }
}
