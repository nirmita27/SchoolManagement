import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IssueBookScreen extends StatefulWidget {
  @override
  _IssueBookScreenState createState() => _IssueBookScreenState();
}

class _IssueBookScreenState extends State<IssueBookScreen> {
  List categories = [];
  List subCategories = [];
  List books = [];
  List students = [];
  int? selectedCategory;
  int? selectedSubCategory;
  int? selectedBook;
  int? selectedStudent;
  DateTime issueDate = DateTime.now();
  DateTime returnDate = DateTime.now().add(Duration(days: 7));
  bool isLoading = false;
  String? errorMessage;

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
      await _fetchCategories();
      await _fetchSubCategories();
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

  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/book-categories'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> _fetchSubCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/subcategories'));
    if (response.statusCode == 200) {
      setState(() {
        subCategories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load subcategories');
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

  Future<void> _issueBook() async {
    if (selectedBook == null || selectedCategory == null || selectedSubCategory == null || selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select all fields')));
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/issue_book'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'book_id': selectedBook,
        'category_id': selectedCategory,
        'sub_category_id': selectedSubCategory,
        'student_id': selectedStudent,
        'quantity': 1,
        'issue_date': issueDate.toIso8601String(),
        'receive_date': returnDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Book issued successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to issue book')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Book'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Category'),
              value: selectedCategory,
              onChanged: (int? newValue) {
                setState(() {
                  selectedCategory = newValue;
                });
              },
              items: categories.map<DropdownMenuItem<int>>((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['book_category_name'] ?? 'N/A'),
                );
              }).toList(),
            ),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Sub Category'),
              value: selectedSubCategory,
              onChanged: (int? newValue) {
                setState(() {
                  selectedSubCategory = newValue;
                });
              },
              items: subCategories.map<DropdownMenuItem<int>>((subCategory) {
                return DropdownMenuItem<int>(
                  value: subCategory['id'],
                  child: Text(subCategory['name'] ?? 'N/A'),
                );
              }).toList(),
            ),
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
                  child: Text(book['book_name'] ?? 'N/A'),
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
                  child: Text('${student['first_name'] ?? 'N/A'} ${student['last_name'] ?? 'N/A'}'),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _issueBook,
              child: Text('Issue Book'),
            ),
          ],
        ),
      ),
    );
  }
}
