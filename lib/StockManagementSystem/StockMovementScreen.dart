import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockMovementScreen extends StatefulWidget {
  @override
  _StockMovementScreenState createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  List<dynamic> stockMovements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStockMovements();
  }

  Future<void> _fetchStockMovements() async {
    final url = Uri.parse('http://localhost:3000/stock-movements');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          stockMovements = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stock movements');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch stock movements. Please try again.');
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

  void _showCreateStockMovementDialog() {
    final _transactionTypeController = TextEditingController();
    final _orderNumberController = TextEditingController();
    final _dateController = TextEditingController();
    final _productController = TextEditingController();
    final _quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Stock Movement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _transactionTypeController,
                decoration: InputDecoration(labelText: 'Transaction Type'),
              ),
              TextField(
                controller: _orderNumberController,
                decoration: InputDecoration(labelText: 'Order Number'),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: _productController,
                decoration: InputDecoration(labelText: 'Product'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
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
            child: Text('Add'),
            onPressed: () {
              final transactionType = _transactionTypeController.text;
              final orderNumber = _orderNumberController.text;
              final date = _dateController.text;
              final product = _productController.text;
              final quantity = _quantityController.text;

              if (transactionType.isNotEmpty &&
                  orderNumber.isNotEmpty &&
                  date.isNotEmpty &&
                  product.isNotEmpty &&
                  quantity.isNotEmpty) {
                _createStockMovement(transactionType, orderNumber, date, product, int.parse(quantity));
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

  void _createStockMovement(String transactionType, String orderNumber, String date, String product, int quantity) async {
    final url = Uri.parse('http://localhost:3000/stock-movements');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'transaction_type': transactionType,
          'order_number': orderNumber,
          'date': date,
          'product': product,
          'quantity': quantity,
        }),
      );
      if (response.statusCode == 201) {
        _fetchStockMovements();
      } else {
        throw Exception('Failed to create stock movement');
      }
    } catch (error) {
      _showErrorDialog('Failed to create stock movement. Please try again.');
    }
  }

  Widget _buildStockMovementTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Transaction Type')),
        DataColumn(label: Text('Order Number')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Product')),
        DataColumn(label: Text('Quantity')),
      ],
      rows: stockMovements
          .asMap()
          .map((index, movement) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(movement['transaction_type'])),
          DataCell(Text(movement['order_number'] ?? 'N/A')),
          DataCell(Text(movement['date'])),
          DataCell(Text(movement['product'])),
          DataCell(Text(movement['quantity'].toString())),
        ]),
      ))
          .values
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Movement List'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: _showCreateStockMovementDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildStockMovementTable(),
        ),
      ),
    );
  }
}
