import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookMasterScreen extends StatefulWidget {
  @override
  _BookMasterScreenState createState() => _BookMasterScreenState();
}

class _BookMasterScreenState extends State<BookMasterScreen> {
  List books = [];
  List categories = [];
  List subCategories = [];
  List publishers = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
    _fetchCategories();
    _fetchSubCategories();
    _fetchPublishers();
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

  Future<void> _fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/categories'));

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

  Future<void> _fetchPublishers() async {
    final response = await http.get(Uri.parse('http://localhost:3000/publishers'));

    if (response.statusCode == 200) {
      setState(() {
        publishers = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load publishers');
    }
  }

  Future<void> _addBook(String accessionNo, String bookName, String author, int publisherId, int categoryId, int subCategoryId, String location, String barCode) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/books'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'accession_no': accessionNo,
        'book_name': bookName,
        'author': author,
        'publisher_id': publisherId,
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
        'location': location,
        'bar_code': barCode,
      }),
    );

    if (response.statusCode == 201) {
      _fetchBooks();
    } else {
      throw Exception('Failed to add book');
    }
  }

  Future<void> _updateBook(int id, String accessionNo, String bookName, String author, int publisherId, int categoryId, int subCategoryId, String location, String barCode) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/books/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'accession_no': accessionNo,
        'book_name': bookName,
        'author': author,
        'publisher_id': publisherId,
        'category_id': categoryId,
        'sub_category_id': subCategoryId,
        'location': location,
        'bar_code': barCode,
      }),
    );

    if (response.statusCode == 200) {
      _fetchBooks();
    } else {
      throw Exception('Failed to update book');
    }
  }

  Future<void> _deleteBook(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/books/$id'));

    if (response.statusCode == 204) {
      _fetchBooks();
    } else {
      throw Exception('Failed to delete book');
    }
  }

  void _showForm({int? id, String? accessionNo, String? bookName, String? author, int? publisherId, int? categoryId, int? subCategoryId, String? location, String? barCode}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController accessionNoController = TextEditingController(text: accessionNo);
    final TextEditingController bookNameController = TextEditingController(text: bookName);
    final TextEditingController authorController = TextEditingController(text: author);
    final TextEditingController locationController = TextEditingController(text: location);
    final TextEditingController barCodeController = TextEditingController(text: barCode);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Book' : 'Edit Book'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: accessionNoController,
                    decoration: InputDecoration(labelText: 'Accession No.'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter an accession number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: bookNameController,
                    decoration: InputDecoration(labelText: 'Book Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a book name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: authorController,
                    decoration: InputDecoration(labelText: 'Author'),
                  ),
                  DropdownButtonFormField<int>(
                    value: publisherId,
                    decoration: InputDecoration(labelText: 'Publisher'),
                    onChanged: (value) {
                      setState(() {
                        publisherId = value;
                      });
                    },
                    items: publishers.map<DropdownMenuItem<int>>((publisher) {
                      return DropdownMenuItem<int>(
                        value: publisher['id'],
                        child: Text(publisher['publisher_name']),
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<int>(
                    value: categoryId,
                    decoration: InputDecoration(labelText: 'Category'),
                    onChanged: (value) {
                      setState(() {
                        categoryId = value;
                      });
                    },
                    items: categories.map<DropdownMenuItem<int>>((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['book_category_name']),
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<int>(
                    value: subCategoryId,
                    decoration: InputDecoration(labelText: 'Sub Category'),
                    onChanged: (value) {
                      setState(() {
                        subCategoryId = value;
                      });
                    },
                    items: subCategories.map<DropdownMenuItem<int>>((subCategory) {
                      return DropdownMenuItem<int>(
                        value: subCategory['id'],
                        child: Text(subCategory['name']),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(labelText: 'Location in Library'),
                  ),
                  TextFormField(
                    controller: barCodeController,
                    decoration: InputDecoration(labelText: 'Bar Code'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(id == null ? 'Add' : 'Update'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (id == null) {
                    _addBook(
                      accessionNoController.text,
                      bookNameController.text,
                      authorController.text,
                      publisherId!,
                      categoryId!,
                      subCategoryId!,
                      locationController.text,
                      barCodeController.text,
                    );
                  } else {
                    _updateBook(
                      id,
                      accessionNoController.text,
                      bookNameController.text,
                      authorController.text,
                      publisherId!,
                      categoryId!,
                      subCategoryId!,
                      locationController.text,
                      barCodeController.text,
                    );
                  }
                  Navigator.of(context).pop();
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
        title: Text('Book Master'),
        backgroundColor: Colors.yellow,
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(books[index]['book_name']),
            subtitle: Text('Accession No: ${books[index]['accession_no']}\nAuthor: ${books[index]['author']}\nLocation: ${books[index]['location']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showForm(
                    id: books[index]['id'],
                    accessionNo: books[index]['accession_no'],
                    bookName: books[index]['book_name'],
                    author: books[index]['author'],
                    publisherId: books[index]['publisher_id'],
                    categoryId: books[index]['category_id'],
                    subCategoryId: books[index]['sub_category_id'],
                    location: books[index]['location'],
                    barCode: books[index]['bar_code'],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteBook(books[index]['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow,
        onPressed: () => _showForm(),
      ),
    );
  }
}
