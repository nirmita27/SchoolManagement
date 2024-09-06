import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VendorScreen extends StatefulWidget {
  @override
  _VendorScreenState createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  List<dynamic> vendors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    final url = Uri.parse('http://localhost:3000/vendors');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          vendors = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load vendors');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch vendors. Please try again.');
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

  void _showCreateVendorDialog() {
    final _vendorNameController = TextEditingController();
    final _vendorTypeController = TextEditingController();
    final _contactNameController = TextEditingController();
    final _phoneNoController = TextEditingController();
    final _emailController = TextEditingController();
    final _websiteController = TextEditingController();
    final _addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create Vendor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vendorNameController,
                decoration: InputDecoration(labelText: 'Vendor Name'),
              ),
              TextField(
                controller: _vendorTypeController,
                decoration: InputDecoration(labelText: 'Vendor Type'),
              ),
              TextField(
                controller: _contactNameController,
                decoration: InputDecoration(labelText: 'Contact Name'),
              ),
              TextField(
                controller: _phoneNoController,
                decoration: InputDecoration(labelText: 'Phone No.'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _websiteController,
                decoration: InputDecoration(labelText: 'Website'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
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
            child: Text('Create'),
            onPressed: () {
              final vendorName = _vendorNameController.text;
              final vendorType = _vendorTypeController.text;
              final contactName = _contactNameController.text;
              final phoneNo = _phoneNoController.text;
              final email = _emailController.text;
              final website = _websiteController.text;
              final address = _addressController.text;

              if (vendorName.isNotEmpty &&
                  vendorType.isNotEmpty &&
                  contactName.isNotEmpty &&
                  phoneNo.isNotEmpty &&
                  email.isNotEmpty &&
                  website.isNotEmpty &&
                  address.isNotEmpty) {
                _createVendor(vendorName, vendorType, contactName, phoneNo, email, website, address);
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

  void _createVendor(String vendorName, String vendorType, String contactName, String phoneNo, String email, String website, String address) async {
    final url = Uri.parse('http://localhost:3000/vendors');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'vendor_name': vendorName,
          'vendor_type': vendorType,
          'contact_name': contactName,
          'phone_no': phoneNo,
          'email': email,
          'website': website,
          'address': address,
        }),
      );
      if (response.statusCode == 201) {
        _fetchVendors();
      } else {
        throw Exception('Failed to create vendor');
      }
    } catch (error) {
      _showErrorDialog('Failed to create vendor. Please try again.');
    }
  }

  void _showEditVendorDialog(int vendorId, String vendorName, String vendorType, String contactName, String phoneNo, String email, String website, String address) {
    final _vendorNameController = TextEditingController(text: vendorName);
    final _vendorTypeController = TextEditingController(text: vendorType);
    final _contactNameController = TextEditingController(text: contactName);
    final _phoneNoController = TextEditingController(text: phoneNo);
    final _emailController = TextEditingController(text: email);
    final _websiteController = TextEditingController(text: website);
    final _addressController = TextEditingController(text: address);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Vendor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _vendorNameController,
                decoration: InputDecoration(labelText: 'Vendor Name'),
              ),
              TextField(
                controller: _vendorTypeController,
                decoration: InputDecoration(labelText: 'Vendor Type'),
              ),
              TextField(
                controller: _contactNameController,
                decoration: InputDecoration(labelText: 'Contact Name'),
              ),
              TextField(
                controller: _phoneNoController,
                decoration: InputDecoration(labelText: 'Phone No.'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _websiteController,
                decoration: InputDecoration(labelText: 'Website'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
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
            child: Text('Update'),
            onPressed: () {
              final newVendorName = _vendorNameController.text;
              final newVendorType = _vendorTypeController.text;
              final newContactName = _contactNameController.text;
              final newPhoneNo = _phoneNoController.text;
              final newEmail = _emailController.text;
              final newWebsite = _websiteController.text;
              final newAddress = _addressController.text;

              if (newVendorName.isNotEmpty &&
                  newVendorType.isNotEmpty &&
                  newContactName.isNotEmpty &&
                  newPhoneNo.isNotEmpty &&
                  newEmail.isNotEmpty &&
                  newWebsite.isNotEmpty &&
                  newAddress.isNotEmpty) {
                _updateVendor(vendorId, newVendorName, newVendorType, newContactName, newPhoneNo, newEmail, newWebsite, newAddress);
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

  void _updateVendor(int vendorId, String vendorName, String vendorType, String contactName, String phoneNo, String email, String website, String address) async {
    final url = Uri.parse('http://localhost:3000/vendors/$vendorId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'vendor_name': vendorName,
          'vendor_type': vendorType,
          'contact_name': contactName,
          'phone_no': phoneNo,
          'email': email,
          'website': website,
          'address': address,
        }),
      );
      if (response.statusCode == 200) {
        _fetchVendors();
      } else {
        throw Exception('Failed to update vendor');
      }
    } catch (error) {
      _showErrorDialog('Failed to update vendor. Please try again.');
    }
  }

  void _deleteVendor(int vendorId) async {
    final url = Uri.parse('http://localhost:3000/vendors/$vendorId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchVendors();
      } else {
        throw Exception('Failed to delete vendor');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete vendor. Please try again.');
    }
  }

  Widget _buildVendorCard(vendor) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(vendor['vendor_name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${vendor['vendor_type']}'),
            Text('Contact: ${vendor['contact_name']}'),
            Text('Phone: ${vendor['phone_no']}'),
            Text('Email: ${vendor['email']}'),
            Text('Website: ${vendor['website']}'),
            Text('Address: ${vendor['address']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(FontAwesomeIcons.edit),
              onPressed: () {
                _showEditVendorDialog(
                  vendor['vendor_id'],
                  vendor['vendor_name'],
                  vendor['vendor_type'],
                  vendor['contact_name'],
                  vendor['phone_no'],
                  vendor['email'],
                  vendor['website'],
                  vendor['address'],
                );
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.trashAlt),
              onPressed: () {
                _deleteVendor(vendor['vendor_id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor List'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: _showCreateVendorDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: vendors.length,
        itemBuilder: (ctx, index) {
          final vendor = vendors[index];
          return _buildVendorCard(vendor);
        },
      ),
    );
  }
}
