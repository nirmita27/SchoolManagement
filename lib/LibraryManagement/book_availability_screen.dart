import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookAvailabilityScreen extends StatefulWidget {
  @override
  _BookAvailabilityScreenState createState() => _BookAvailabilityScreenState();
}

class _BookAvailabilityScreenState extends State<BookAvailabilityScreen> {
  List books = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/book_availability'));
      if (response.statusCode == 200) {
        setState(() {
          books = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load books');
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

  void _showNextAvailability(int bookId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return NextAvailabilitySheet(bookId: bookId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Book Availability'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              child: ListTile(
                title: Text(book['book_name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category: ${book['book_category_name']}'),
                    Text('Issuable: ${book['issuable']}'),
                    Text('Total Quantity: ${book['total_quantity']}'),
                    Text('Issued: ${book['issued_quantity']}'),
                    Text('Available: ${book['available_quantity']}'),
                    if (book['available_quantity'] == 0) Text('Next Availability: ${book['next_availability'] ?? "N/A"}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () => _showNextAvailability(book['id']),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NextAvailabilitySheet extends StatefulWidget {
  final int bookId;

  NextAvailabilitySheet({required this.bookId});

  @override
  _NextAvailabilitySheetState createState() => _NextAvailabilitySheetState();
}

class _NextAvailabilitySheetState extends State<NextAvailabilitySheet> {
  List nextAvailability = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNextAvailability();
  }

  Future<void> _fetchNextAvailability() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/next_availability/${widget.bookId}'));
      if (response.statusCode == 200) {
        setState(() {
          nextAvailability = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load next availability');
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView.builder(
        itemCount: nextAvailability.length,
        itemBuilder: (context, index) {
          final availability = nextAvailability[index];
          return ListTile(
            title: Text('Receive Date: ${availability['received_date']}'),
            subtitle: Text('Quantity: ${availability['quantity']}'),
          );
        },
      ),
    );
  }
}
