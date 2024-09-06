import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockCategoryScreen extends StatefulWidget {
  @override
  _StockCategoryScreenState createState() => _StockCategoryScreenState();
}

class _StockCategoryScreenState extends State<StockCategoryScreen> {
  List<dynamic> stockCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStockCategories();
  }

  Future<void> _fetchStockCategories() async {
    final url = Uri.parse('http://localhost:3000/stock-categories');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          stockCategories = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stock categories');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch stock categories. Please try again.');
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

  void _showCreateCategoryDialog() {
    final _categoryNameController = TextEditingController();
    final _stockCodeController = TextEditingController();
    final _orderNoController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create Stock Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(labelText: 'Stock Category Name'),
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
              final stockCode = _stockCodeController.text;
              final orderNo = _orderNoController.text;

              if (categoryName.isNotEmpty &&
                  stockCode.isNotEmpty &&
                  orderNo.isNotEmpty) {
                _createStockCategory(categoryName, stockCode, int.parse(orderNo));
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

  void _createStockCategory(String categoryName, String stockCode, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/stock-categories');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category_name': categoryName,
          'stock_code': stockCode,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 201) {
        _fetchStockCategories();
      } else {
        throw Exception('Failed to create stock category');
      }
    } catch (error) {
      _showErrorDialog('Failed to create stock category. Please try again.');
    }
  }

  void _showEditCategoryDialog(int categoryId, String categoryName, String stockCode, int orderNo) {
    final _categoryNameController = TextEditingController(text: categoryName);
    final _stockCodeController = TextEditingController(text: stockCode);
    final _orderNoController = TextEditingController(text: orderNo.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Stock Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _categoryNameController,
                decoration: InputDecoration(labelText: 'Stock Category Name'),
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
              final newStockCode = _stockCodeController.text;
              final newOrderNo = int.parse(_orderNoController.text);

              if (newCategoryName.isNotEmpty &&
                  newStockCode.isNotEmpty &&
                  newOrderNo != null) {
                _updateStockCategory(categoryId, newCategoryName, newStockCode, newOrderNo);
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

  void _updateStockCategory(int categoryId, String categoryName, String stockCode, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/stock-categories/$categoryId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category_name': categoryName,
          'stock_code': stockCode,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 200) {
        _fetchStockCategories();
      } else {
        throw Exception('Failed to update stock category');
      }
    } catch (error) {
      _showErrorDialog('Failed to update stock category. Please try again.');
    }
  }

  void _deleteStockCategory(int categoryId) async {
    final url = Uri.parse('http://localhost:3000/stock-categories/$categoryId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchStockCategories();
      } else {
        throw Exception('Failed to delete stock category');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete stock category. Please try again.');
    }
  }

  Widget _buildStockCategoryCard(stockCategory) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(stockCategory['category_name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock Code: ${stockCategory['stock_code']}'),
            Text('Order No: ${stockCategory['order_no']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(FontAwesomeIcons.edit),
              onPressed: () {
                _showEditCategoryDialog(
                  stockCategory['category_id'],
                  stockCategory['category_name'],
                  stockCategory['stock_code'],
                  stockCategory['order_no'],
                );
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.trashAlt),
              onPressed: () {
                _deleteStockCategory(stockCategory['category_id']);
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
        title: Text('Stock Category'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: _showCreateCategoryDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: stockCategories.length,
        itemBuilder: (ctx, index) {
          final stockCategory = stockCategories[index];
          return _buildStockCategoryCard(stockCategory);
        },
      ),
    );
  }
}
