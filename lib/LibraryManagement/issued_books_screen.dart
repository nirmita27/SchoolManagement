import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IssuedBooksScreen extends StatefulWidget {
  @override
  _IssuedBooksScreenState createState() => _IssuedBooksScreenState();
}

class _IssuedBooksScreenState extends State<IssuedBooksScreen> {
  List issuedBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchIssuedBooks();
  }

  Future<void> _fetchIssuedBooks() async {
    final response = await http.get(Uri.parse('http://localhost:3000/issued_books'));
    if (response.statusCode == 200) {
      setState(() {
        issuedBooks = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load issued books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issued Books'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: issuedBooks.length,
          itemBuilder: (context, index) {
            final book = issuedBooks[index];
            return Card(
              child: ListTile(
                title: Text(book['book']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: ${book['category']}'),
                    Text('SubCategory: ${book['sub_category']}'),
                    Text('Student: ${book['name']}'),
                    Text('Quantity: ${book['quantity']}'),
                    Text('Issue Date: ${book['issue_date']}'),
                    Text('Receive Date: ${book['receive_date'] ?? 'N/A'}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/issueBook');
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
