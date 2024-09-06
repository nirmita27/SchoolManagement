import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScrapBookScreen extends StatefulWidget {
  @override
  _ScrapBookScreenState createState() => _ScrapBookScreenState();
}

class _ScrapBookScreenState extends State<ScrapBookScreen> {
  List scrappedBooks = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchScrappedBooks();
  }

  Future<void> _fetchScrappedBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/scrapped_books?search=$searchQuery'));
      if (response.statusCode == 200) {
        setState(() {
          scrappedBooks = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load scrapped books');
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

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _fetchScrappedBooks();
  }

  void _scrapBook() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScrapNewBookScreen(),
      ),
    ).then((value) {
      if (value == true) {
        _fetchScrappedBooks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scrap a Book'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search a Book',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : scrappedBooks.isEmpty
                ? Center(child: Text('No Records Found.'))
                : ListView.builder(
              itemCount: scrappedBooks.length,
              itemBuilder: (context, index) {
                final book = scrappedBooks[index];
                return Card(
                  child: ListTile(
                    title: Text(book['book_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Book Category: ${book['book_category_name']}'),
                        Text('Quantity: ${book['quantity']}'),
                        Text('Scrap Date: ${book['scrap_date']}'),
                        Text('Scrap Reason: ${book['scrap_reason']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrapBook,
        child: Icon(Icons.add),
        tooltip: 'Scrap a Book',
      ),
    );
  }
}

class ScrapNewBookScreen extends StatefulWidget {
  @override
  _ScrapNewBookScreenState createState() => _ScrapNewBookScreenState();
}

class _ScrapNewBookScreenState extends State<ScrapNewBookScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _bookId;
  int? _quantity;
  DateTime _scrapDate = DateTime.now();
  String _scrapReason = '';

  Future<void> _submitScrapBook() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final response = await http.post(
      Uri.parse('http://localhost:3000/scrap_book'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'book_id': _bookId,
        'quantity': _quantity,
        'scrap_date': _scrapDate.toIso8601String(),
        'scrap_reason': _scrapReason,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scrap book. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scrap a New Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Select Book',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<int>(value: 1, child: Text('Dune')),
                  DropdownMenuItem<int>(value: 2, child: Text('Sapiens: A Brief History of Humankind')),
                  DropdownMenuItem<int>(value: 3, child: Text('Steve Jobs')),
                  DropdownMenuItem<int>(value: 4, child: Text('The Hobbit')),
                  DropdownMenuItem<int>(value: 5, child: Text('The Da Vinci Code')),
                ],
                onChanged: (value) {
                  setState(() {
                    _bookId = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Please select a book';
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _quantity = int.tryParse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a quantity';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Scrap Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _scrapReason = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a reason';
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitScrapBook,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
