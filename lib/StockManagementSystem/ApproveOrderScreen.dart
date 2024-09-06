import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApproveOrderScreen extends StatefulWidget {
  @override
  _ApproveOrderScreenState createState() => _ApproveOrderScreenState();
}

class _ApproveOrderScreenState extends State<ApproveOrderScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final url = Uri.parse('http://localhost:3000/orders');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          orders = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch orders. Please try again.');
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

  void _showChangeStatusDialog(int id, String currentStatus) {
    final _statusController = TextEditingController(text: currentStatus);
    final _replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: currentStatus,
                items: ['Pending', 'Approved', 'Cancelled']
                    .map((status) => DropdownMenuItem(
                  child: Text(status),
                  value: status,
                ))
                    .toList(),
                onChanged: (value) {
                  _statusController.text = value!;
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: _replyController,
                decoration: InputDecoration(labelText: 'Enter Reply'),
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
            child: Text('Save'),
            onPressed: () {
              final status = _statusController.text;
              final reply = _replyController.text;

              if (status.isNotEmpty && reply.isNotEmpty) {
                _changeOrderStatus(id, status, reply);
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

  void _changeOrderStatus(int id, String status, String reply) async {
    final url = Uri.parse('http://localhost:3000/orders/$id/status');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status, 'reply': reply}),
      );
      if (response.statusCode == 200) {
        _fetchOrders();
      } else {
        throw Exception('Failed to change order status');
      }
    } catch (error) {
      _showErrorDialog('Failed to change order status. Please try again.');
    }
  }

  void _showRemarksDialog(int id) async {
    final url = Uri.parse('http://localhost:3000/orders/$id/remarks');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final remarks = json.decode(response.body);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('View Remark'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Posted By: ${remarks['posted_by']}'),
                  Text('Posted On: ${remarks['posted_on']}'),
                  Text('${remarks['remark']}'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to fetch remarks');
      }
    } catch (error) {
      _showErrorDialog('Failed to fetch remarks. Please try again.');
    }
  }

  void _showItemsDialog(int id) async {
    final url = Uri.parse('http://localhost:3000/orders/$id/items');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final items = json.decode(response.body);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Purchase Item List'),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Product Name')),
                  DataColumn(label: Text('Stock Qty')),
                  DataColumn(label: Text('Order Quantity')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Total Price')),
                ],
                rows: items
                    .map<DataRow>((item) => DataRow(cells: [
                  DataCell(Text(item['product_name'])),
                  DataCell(Text(item['stock_qty'].toString())),
                  DataCell(Text(item['order_quantity'].toString())),
                  DataCell(Text(item['price'].toString())),
                  DataCell(Text(item['total_price'].toString())),
                ]))
                    .toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to fetch items');
      }
    } catch (error) {
      _showErrorDialog('Failed to fetch items. Please try again.');
    }
  }

  Widget _buildOrderTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Po No')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Category')),
        DataColumn(label: Text('Gross Amount')),
        DataColumn(label: Text('Tax Amount')),
        DataColumn(label: Text('Net Amount')),
        DataColumn(label: Text('Attachment')),
        DataColumn(label: Text('Actions')),
      ],
      rows: orders
          .asMap()
          .map((index, order) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(order['po_no'])),
          DataCell(Text(order['date'])),
          DataCell(Text(order['category'])),
          DataCell(Text(order['gross_amount'].toString())),
          DataCell(Text(order['tax_amount'].toString())),
          DataCell(Text(order['net_amount'].toString())),
          DataCell(Text('')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showChangeStatusDialog(order['id'], order['status']);
                },
              ),
              TextButton(
                child: Text('Remark'),
                onPressed: () {
                  _showRemarksDialog(order['id']);
                },
              ),
              TextButton(
                child: Text('Items'),
                onPressed: () {
                  _showItemsDialog(order['id']);
                },
              ),
            ],
          )),
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
        title: Text('Approve Order List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildOrderTable(),
        ),
      ),
    );
  }
}
