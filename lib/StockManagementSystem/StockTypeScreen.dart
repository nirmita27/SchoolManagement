import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockTypeScreen extends StatefulWidget {
  @override
  _StockTypeScreenState createState() => _StockTypeScreenState();
}

class _StockTypeScreenState extends State<StockTypeScreen> {
  List<dynamic> stockTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStockTypes();
  }

  Future<void> _fetchStockTypes() async {
    final url = Uri.parse('http://localhost:3000/stock-types');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          stockTypes = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stock types');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch stock types. Please try again.');
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

  void _showCreateTypeDialog() {
    final _categoryNameController = TextEditingController();
    final _typeNameController = TextEditingController();
    final _stockCodeController = TextEditingController();
    final _orderNoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create Stock Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(labelText: 'Stock Category Name'),
              ),
              TextField(
                controller: _typeNameController,
                decoration: InputDecoration(labelText: 'Stock Type Name'),
              ),
              TextField(
                controller: _stockCodeController,
                decoration: InputDecoration(labelText: 'Stock Code'),
              ),
              TextField(
                controller: _orderNoController,
                decoration: InputDecoration(labelText: 'Order No'),
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
            child: Text('Create'),
            onPressed: () {
              final categoryName = _categoryNameController.text;
              final typeName = _typeNameController.text;
              final stockCode = _stockCodeController.text;
              final orderNo = _orderNoController.text;

              if (categoryName.isNotEmpty &&
                  typeName.isNotEmpty &&
                  stockCode.isNotEmpty &&
                  orderNo.isNotEmpty) {
                _createStockType(categoryName, typeName, stockCode, int.parse(orderNo));
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

  void _createStockType(String categoryName, String typeName, String stockCode, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/stock-types');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category_name': categoryName,
          'type_name': typeName,
          'stock_code': stockCode,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 201) {
        _fetchStockTypes();
      } else {
        throw Exception('Failed to create stock type');
      }
    } catch (error) {
      _showErrorDialog('Failed to create stock type. Please try again.');
    }
  }

  void _showEditTypeDialog(int typeId, String categoryName, String typeName, String stockCode, int orderNo) {
    final _categoryNameController = TextEditingController(text: categoryName);
    final _typeNameController = TextEditingController(text: typeName);
    final _stockCodeController = TextEditingController(text: stockCode);
    final _orderNoController = TextEditingController(text: orderNo.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Stock Type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(labelText: 'Stock Category Name'),
              ),
              TextField(
                controller: _typeNameController,
                decoration: InputDecoration(labelText: 'Stock Type Name'),
              ),
              TextField(
                controller: _stockCodeController,
                decoration: InputDecoration(labelText: 'Stock Code'),
              ),
              TextField(
                controller: _orderNoController,
                decoration: InputDecoration(labelText: 'Order No'),
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
            child: Text('Update'),
            onPressed: () {
              final newCategoryName = _categoryNameController.text;
              final newTypeName = _typeNameController.text;
              final newStockCode = _stockCodeController.text;
              final newOrderNo = int.parse(_orderNoController.text);

              if (newCategoryName.isNotEmpty &&
                  newTypeName.isNotEmpty &&
                  newStockCode.isNotEmpty &&
                  newOrderNo != null) {
                _updateStockType(typeId, newCategoryName, newTypeName, newStockCode, newOrderNo);
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

  void _updateStockType(int typeId, String categoryName, String typeName, String stockCode, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/stock-types/$typeId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category_name': categoryName,
          'type_name': typeName,
          'stock_code': stockCode,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 200) {
        _fetchStockTypes();
      } else {
        throw Exception('Failed to update stock type');
      }
    } catch (error) {
      _showErrorDialog('Failed to update stock type. Please try again.');
    }
  }

  void _deleteStockType(int typeId) async {
    final url = Uri.parse('http://localhost:3000/stock-types/$typeId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchStockTypes();
      } else {
        throw Exception('Failed to delete stock type');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete stock type. Please try again.');
    }
  }

  Widget _buildStockTypeCard(stockType) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(stockType['type_name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${stockType['category_name']}'),
            Text('Stock Code: ${stockType['stock_code']}'),
            Text('Order No: ${stockType['order_no']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(FontAwesomeIcons.edit),
              onPressed: () {
                _showEditTypeDialog(
                  stockType['type_id'],
                  stockType['category_name'],
                  stockType['type_name'],
                  stockType['stock_code'],
                  stockType['order_no'],
                );
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.trashAlt),
              onPressed: () {
                _deleteStockType(stockType['type_id']);
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
        title: Text('Stock Type'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: _showCreateTypeDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: stockTypes.length,
        itemBuilder: (ctx, index) {
          final stockType = stockTypes[index];
          return _buildStockTypeCard(stockType);
        },
      ),
    );
  }
}
