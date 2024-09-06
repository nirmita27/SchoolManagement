import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookPublisherScreen extends StatefulWidget {
  @override
  _BookPublisherScreenState createState() => _BookPublisherScreenState();
}

class _BookPublisherScreenState extends State<BookPublisherScreen> {
  List publishers = [];

  @override
  void initState() {
    super.initState();
    _fetchPublishers();
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

  Future<void> _addPublisher(String publisherName, String phoneNo, String emailAddress, String address) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/publishers'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'publisher_name': publisherName,
        'phone_no': phoneNo,
        'email_address': emailAddress,
        'address': address,
      }),
    );

    if (response.statusCode == 201) {
      _fetchPublishers();
    } else {
      throw Exception('Failed to add publisher');
    }
  }

  Future<void> _updatePublisher(int id, String publisherName, String phoneNo, String emailAddress, String address) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/publishers/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'publisher_name': publisherName,
        'phone_no': phoneNo,
        'email_address': emailAddress,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      _fetchPublishers();
    } else {
      throw Exception('Failed to update publisher');
    }
  }

  Future<void> _deletePublisher(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/publishers/$id'));

    if (response.statusCode == 204) {
      _fetchPublishers();
    } else {
      throw Exception('Failed to delete publisher');
    }
  }

  void _showForm({int? id, String? publisherName, String? phoneNo, String? emailAddress, String? address}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(text: publisherName);
    final TextEditingController phoneNoController = TextEditingController(text: phoneNo);
    final TextEditingController emailAddressController = TextEditingController(text: emailAddress);
    final TextEditingController addressController = TextEditingController(text: address);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Publisher' : 'Edit Publisher'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Publisher Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: phoneNoController,
                  decoration: InputDecoration(labelText: 'Phone No'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: emailAddressController,
                  decoration: InputDecoration(labelText: 'Email Address'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
              ],
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
                    _addPublisher(
                      nameController.text,
                      phoneNoController.text,
                      emailAddressController.text,
                      addressController.text,
                    );
                  } else {
                    _updatePublisher(
                      id,
                      nameController.text,
                      phoneNoController.text,
                      emailAddressController.text,
                      addressController.text,
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
        title: Text('Book Publisher'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: publishers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(publishers[index]['publisher_name']),
            subtitle: Text('Phone: ${publishers[index]['phone_no']}\nEmail: ${publishers[index]['email_address']}\nAddress: ${publishers[index]['address']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showForm(
                    id: publishers[index]['id'],
                    publisherName: publishers[index]['publisher_name'],
                    phoneNo: publishers[index]['phone_no'],
                    emailAddress: publishers[index]['email_address'],
                    address: publishers[index]['address'],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deletePublisher(publishers[index]['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showForm(),
      ),
    );
  }
}
