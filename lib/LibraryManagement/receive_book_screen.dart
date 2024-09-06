import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceiveBookScreen extends StatefulWidget {
  @override
  _ReceiveBookScreenState createState() => _ReceiveBookScreenState();
}

class _ReceiveBookScreenState extends State<ReceiveBookScreen> {
  List receivedBooks = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReceivedBooks();
  }

  Future<void> _fetchReceivedBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/received_books'));
      if (response.statusCode == 200) {
        setState(() {
          receivedBooks = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load received books');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showReceiveBookForm() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddReceiveBookForm(onBookReceived: _fetchReceivedBooks);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Received Books'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: receivedBooks.length,
          itemBuilder: (context, index) {
            final book = receivedBooks[index];
            return Card(
              child: ListTile(
                title: Text(book['book']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Issued To: ${book['issued_name']}'),
                    Text('Quantity: ${book['quantity']}'),
                    Text('Issue Date: ${book['issue_date']}'),
                    Text('Return Date: ${book['return_date']}'),
                    Text('Received Date: ${book['received_date']}'),
                    Text('Fine: ${book['fine']}'),
                    Text('Paid: ${book['paid'] ? "Yes" : "No"}'),
                    Text('Remarks: ${book['remarks']}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showReceiveBookForm,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class AddReceiveBookForm extends StatefulWidget {
  final Function onBookReceived;

  AddReceiveBookForm({required this.onBookReceived});

  @override
  _AddReceiveBookFormState createState() => _AddReceiveBookFormState();
}

class _AddReceiveBookFormState extends State<AddReceiveBookForm> {
  final _formKey = GlobalKey<FormState>();
  List books = [];
  List students = [];
  int? selectedBook;
  int? selectedStudent;
  DateTime receivedDate = DateTime.now();
  DateTime issueDate = DateTime.now(); // Default to current date
  DateTime returnDate = DateTime.now().add(Duration(days: 7)); // Default to a week from now
  String remarks = '';
  bool isLoading = false;
  String? errorMessage;
  double fine = 0.0;
  bool paid = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _fetchBooks();
      await _fetchStudents();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchBooks() async {
    final response = await http.get(Uri.parse('http://localhost:3000/books'));
    if (response.statusCode == 200) {
      setState(() {
        books = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<void> _fetchStudents() async {
    final response = await http.get(Uri.parse('http://localhost:3000/students'));
    if (response.statusCode == 200) {
      setState(() {
        students = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<void> _receiveBook() async {
    if (selectedBook == null || selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a book and student')));
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/receive_book'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'book_id': selectedBook,
        'issued_to': selectedStudent,
        'quantity': 1,
        'issue_date': issueDate.toIso8601String(), // Set the correct issue date
        'return_date': returnDate.toIso8601String(), // Set the correct return date
        'received_date': receivedDate.toIso8601String(),
        'fine': fine,
        'paid': paid,
        'remarks': remarks,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book received successfully')));
      widget.onBookReceived();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to receive book')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Select Book'),
                value: selectedBook,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedBook = newValue;
                  });
                },
                items: books.map<DropdownMenuItem<int>>((book) {
                  return DropdownMenuItem<int>(
                    value: book['id'],
                    child: Text(book['book_name']),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Select Student/Staff'),
                value: selectedStudent,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedStudent = newValue;
                  });
                },
                items: students.map<DropdownMenuItem<int>>((student) {
                  return DropdownMenuItem<int>(
                    value: student['student_id'],
                    child: Text(student['first_name'] + ' ' + student['last_name']),
                  );
                }).toList(),
              ),
              ListTile(
                title: Text('Issue Date'),
                subtitle: Text('${issueDate.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: issueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != issueDate)
                    setState(() {
                      issueDate = picked;
                    });
                },
              ),
              ListTile(
                title: Text('Return Date'),
                subtitle: Text('${returnDate.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: returnDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != returnDate)
                    setState(() {
                      returnDate = picked;
                    });
                },
              ),
              ListTile(
                title: Text('Received Date'),
                subtitle: Text('${receivedDate.toLocal()}'.split(' ')[0]),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: receivedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != receivedDate)
                    setState(() {
                      receivedDate = picked;
                    });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Fine'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    fine = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Paid'),
                value: paid,
                onChanged: (bool value) {
                  setState(() {
                    paid = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Remarks'),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    remarks = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _receiveBook,
                child: Text('Receive Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
