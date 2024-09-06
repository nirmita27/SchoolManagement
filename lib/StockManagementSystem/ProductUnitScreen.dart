import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductUnitScreen extends StatefulWidget {
  @override
  _ProductUnitScreenState createState() => _ProductUnitScreenState();
}

class _ProductUnitScreenState extends State<ProductUnitScreen> {
  List<dynamic> productUnits = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductUnits();
  }

  Future<void> _fetchProductUnits() async {
    final url = Uri.parse('http://localhost:3000/product-units');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          productUnits = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load product units');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch product units. Please try again.');
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

  void _showCreateUnitDialog() {
    final _unitNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create Product Unit'),
        content: TextField(
          controller: _unitNameController,
          decoration: InputDecoration(labelText: 'Unit Name'),
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
              final unitName = _unitNameController.text;

              if (unitName.isNotEmpty) {
                _createProductUnit(unitName);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill the unit name.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _createProductUnit(String unitName) async {
    final url = Uri.parse('http://localhost:3000/product-units');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'unit_name': unitName}),
      );
      if (response.statusCode == 201) {
        _fetchProductUnits();
      } else {
        throw Exception('Failed to create product unit');
      }
    } catch (error) {
      _showErrorDialog('Failed to create product unit. Please try again.');
    }
  }

  void _showEditUnitDialog(int unitId, String unitName) {
    final _unitNameController = TextEditingController(text: unitName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Product Unit'),
        content: TextField(
          controller: _unitNameController,
          decoration: InputDecoration(labelText: 'Unit Name'),
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
              final newUnitName = _unitNameController.text;

              if (newUnitName.isNotEmpty) {
                _updateProductUnit(unitId, newUnitName);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill the unit name.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateProductUnit(int unitId, String unitName) async {
    final url = Uri.parse('http://localhost:3000/product-units/$unitId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'unit_name': unitName}),
      );
      if (response.statusCode == 200) {
        _fetchProductUnits();
      } else {
        throw Exception('Failed to update product unit');
      }
    } catch (error) {
      _showErrorDialog('Failed to update product unit. Please try again.');
    }
  }

  void _deleteProductUnit(int unitId) async {
    final url = Uri.parse('http://localhost:3000/product-units/$unitId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchProductUnits();
      } else {
        throw Exception('Failed to delete product unit');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete product unit. Please try again.');
    }
  }

  Widget _buildProductUnitCard(productUnit) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(productUnit['unit_name']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(FontAwesomeIcons.edit),
              onPressed: () {
                _showEditUnitDialog(
                  productUnit['unit_id'],
                  productUnit['unit_name'],
                );
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.trashAlt),
              onPressed: () {
                _deleteProductUnit(productUnit['unit_id']);
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
        title: Text('Product Unit'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: _showCreateUnitDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: productUnits.length,
        itemBuilder: (ctx, index) {
          final productUnit = productUnits[index];
          return _buildProductUnitCard(productUnit);
        },
      ),
    );
  }
}
