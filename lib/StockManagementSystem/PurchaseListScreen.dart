import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PurchaseListScreen extends StatefulWidget {
  @override
  _PurchaseListScreenState createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  List<dynamic> purchases = [];
  List<dynamic> branches = [];
  List<dynamic> stockCategories = [];
  List<dynamic> stockTypes = [];
  List<dynamic> vendors = [];
  bool isLoading = true;
  bool isDropdownLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
    _fetchDropdownData();
  }

  Future<void> _fetchPurchases() async {
    final url = Uri.parse('http://localhost:3000/purchases');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          purchases = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load purchases');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch purchases. Please try again.');
    }
  }

  Future<void> _fetchDropdownData() async {
    try {
      final branchesResponse = await http.get(Uri.parse('http://localhost:3000/branches'));
      final categoriesResponse = await http.get(Uri.parse('http://localhost:3000/stock-categories'));
      final typesResponse = await http.get(Uri.parse('http://localhost:3000/stock-types'));
      final vendorsResponse = await http.get(Uri.parse('http://localhost:3000/vendors'));

      if (branchesResponse.statusCode == 200 &&
          categoriesResponse.statusCode == 200 &&
          typesResponse.statusCode == 200 &&
          vendorsResponse.statusCode == 200) {
        setState(() {
          branches = json.decode(branchesResponse.body);
          stockCategories = json.decode(categoriesResponse.body);
          stockTypes = json.decode(typesResponse.body);
          vendors = json.decode(vendorsResponse.body);
          isDropdownLoading = false;
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    } catch (error) {
      setState(() {
        isDropdownLoading = false;
      });
      _showErrorDialog('Failed to fetch dropdown data. Please try again.');
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

  void _showCreatePurchaseDialog() {
    final _branchController = TextEditingController();
    final _categoryController = TextEditingController();
    final _vendorController = TextEditingController();
    final _typeController = TextEditingController();
    final _dateController = TextEditingController();
    final _approverController = TextEditingController();
    final _productController = TextEditingController();
    final _quantityController = TextEditingController();
    final _priceController = TextEditingController();
    final _unitController = TextEditingController();
    final _discountController = TextEditingController();
    final _grossController = TextEditingController();
    final _taxController = TextEditingController();
    final _netController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Purchase'),
        content: SingleChildScrollView(
          child: isDropdownLoading
              ? CircularProgressIndicator()
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                items: branches.map<DropdownMenuItem<String>>((branch) {
                  return DropdownMenuItem<String>(
                    value: branch['branch_name'],
                    child: Text(branch['branch_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Branch'),
                onChanged: (value) {
                  _branchController.text = value.toString();
                },
              ),
              DropdownButtonFormField(
                items: stockCategories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['category_name'],
                    child: Text(category['category_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Category'),
                onChanged: (value) {
                  _categoryController.text = value.toString();
                },
              ),
              DropdownButtonFormField(
                items: vendors.map<DropdownMenuItem<String>>((vendor) {
                  return DropdownMenuItem<String>(
                    value: vendor['vendor_name'],
                    child: Text(vendor['vendor_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Vendor'),
                onChanged: (value) {
                  _vendorController.text = value.toString();
                },
              ),
              DropdownButtonFormField(
                items: stockTypes.map<DropdownMenuItem<String>>((type) {
                  return DropdownMenuItem<String>(
                    value: type['type_name'],
                    child: Text(type['type_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Stock Type'),
                onChanged: (value) {
                  _typeController.text = value.toString();
                },
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: _approverController,
                decoration: InputDecoration(labelText: 'Approver'),
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
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price Per Unit'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _unitController,
                decoration: InputDecoration(labelText: 'Unit'),
              ),
              TextField(
                controller: _discountController,
                decoration: InputDecoration(labelText: 'Discount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _grossController,
                decoration: InputDecoration(labelText: 'Gross'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _taxController,
                decoration: InputDecoration(labelText: 'Tax'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _netController,
                decoration: InputDecoration(labelText: 'Net'),
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
              final branch = _branchController.text;
              final category = _categoryController.text;
              final vendor = _vendorController.text;
              final type = _typeController.text;
              final date = _dateController.text;
              final approver = _approverController.text;
              final product = _productController.text;
              final quantity = _quantityController.text;
              final price = _priceController.text;
              final unit = _unitController.text;
              final discount = _discountController.text;
              final gross = _grossController.text;
              final tax = _taxController.text;
              final net = _netController.text;

              if (branch.isNotEmpty &&
                  category.isNotEmpty &&
                  vendor.isNotEmpty &&
                  type.isNotEmpty &&
                  date.isNotEmpty &&
                  approver.isNotEmpty &&
                  product.isNotEmpty &&
                  quantity.isNotEmpty &&
                  price.isNotEmpty &&
                  unit.isNotEmpty &&
                  discount.isNotEmpty &&
                  gross.isNotEmpty &&
                  tax.isNotEmpty &&
                  net.isNotEmpty) {
                _createPurchase(branch, category, vendor, type, date, approver, product, int.parse(quantity), double.parse(price), unit, double.parse(discount), double.parse(gross), double.parse(tax), double.parse(net));
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

  void _createPurchase(String branch, String category, String vendor, String type, String date, String approver, String product, int quantity, double price, String unit, double discount, double gross, double tax, double net) async {
    final url = Uri.parse('http://localhost:3000/purchases');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'branch': branch,
          'category': category,
          'vendor': vendor,
          'type': type,
          'date': date,
          'approver': approver,
          'product': product,
          'quantity': quantity,
          'price': price,
          'unit': unit,
          'discount': discount,
          'gross': gross,
          'tax': tax,
          'net': net,
        }),
      );
      if (response.statusCode == 201) {
        _fetchPurchases();
      } else {
        throw Exception('Failed to create purchase');
      }
    } catch (error) {
      _showErrorDialog('Failed to create purchase. Please try again.');
    }
  }

  void _showEditPurchaseDialog(int id, String branch, String category, String vendor, String type, String date, String approver, String product, int quantity, double price, String unit, double discount, double gross, double tax, double net) {
    final _branchController = TextEditingController(text: branch);
    final _categoryController = TextEditingController(text: category);
    final _vendorController = TextEditingController(text: vendor);
    final _typeController = TextEditingController(text: type);
    final _dateController = TextEditingController(text: date);
    final _approverController = TextEditingController(text: approver);
    final _productController = TextEditingController(text: product);
    final _quantityController = TextEditingController(text: quantity.toString());
    final _priceController = TextEditingController(text: price.toString());
    final _unitController = TextEditingController(text: unit);
    final _discountController = TextEditingController(text: discount.toString());
    final _grossController = TextEditingController(text: gross.toString());
    final _taxController = TextEditingController(text: tax.toString());
    final _netController = TextEditingController(text: net.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Purchase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _branchController,
                decoration: InputDecoration(labelText: 'Branch'),
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: _vendorController,
                decoration: InputDecoration(labelText: 'Vendor'),
              ),
              TextField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Stock Type'),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                keyboardType: TextInputType.datetime,
              ),
              TextField(
                controller: _approverController,
                decoration: InputDecoration(labelText: 'Approver'),
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
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price Per Unit'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _unitController,
                decoration: InputDecoration(labelText: 'Unit'),
              ),
              TextField(
                controller: _discountController,
                decoration: InputDecoration(labelText: 'Discount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _grossController,
                decoration: InputDecoration(labelText: 'Gross'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _taxController,
                decoration: InputDecoration(labelText: 'Tax'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _netController,
                decoration: InputDecoration(labelText: 'Net'),
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
            child: Text('Save'),
            onPressed: () {
              final updatedBranch = _branchController.text;
              final updatedCategory = _categoryController.text;
              final updatedVendor = _vendorController.text;
              final updatedType = _typeController.text;
              final updatedDate = _dateController.text;
              final updatedApprover = _approverController.text;
              final updatedProduct = _productController.text;
              final updatedQuantity = int.parse(_quantityController.text);
              final updatedPrice = double.parse(_priceController.text);
              final updatedUnit = _unitController.text;
              final updatedDiscount = double.parse(_discountController.text);
              final updatedGross = double.parse(_grossController.text);
              final updatedTax = double.parse(_taxController.text);
              final updatedNet = double.parse(_netController.text);

              if (updatedBranch.isNotEmpty &&
                  updatedCategory.isNotEmpty &&
                  updatedVendor.isNotEmpty &&
                  updatedType.isNotEmpty &&
                  updatedDate.isNotEmpty &&
                  updatedApprover.isNotEmpty &&
                  updatedProduct.isNotEmpty &&
                  updatedQuantity > 0 &&
                  updatedPrice > 0 &&
                  updatedUnit.isNotEmpty &&
                  updatedDiscount >= 0 &&
                  updatedGross >= 0 &&
                  updatedTax >= 0 &&
                  updatedNet >= 0) {
                _editPurchase(id, updatedBranch, updatedCategory, updatedVendor, updatedType, updatedDate, updatedApprover, updatedProduct, updatedQuantity, updatedPrice, updatedUnit, updatedDiscount, updatedGross, updatedTax, updatedNet);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields with valid values.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _editPurchase(int id, String branch, String category, String vendor, String type, String date, String approver, String product, int quantity, double price, String unit, double discount, double gross, double tax, double net) async {
    final url = Uri.parse('http://localhost:3000/purchases/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'branch': branch,
          'category': category,
          'vendor': vendor,
          'type': type,
          'date': date,
          'approver': approver,
          'product': product,
          'quantity': quantity,
          'price': price,
          'unit': unit,
          'discount': discount,
          'gross': gross,
          'tax': tax,
          'net': net,
        }),
      );
      if (response.statusCode == 200) {
        _fetchPurchases();
      } else {
        throw Exception('Failed to edit purchase');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit purchase. Please try again.');
    }
  }

  void _deletePurchase(int id) async {
    final url = Uri.parse('http://localhost:3000/purchases/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchPurchases();
      } else {
        throw Exception('Failed to delete purchase');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete purchase. Please try again.');
    }
  }

  void _showReceiptDialog(purchase) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ORDER RECEIPT'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ORDER RECEIPT\n'),
              Text('Order No.: ${purchase['purchase_no']}'),
              Text('Date: ${purchase['date']}'),
              Text('Vendor Name: ${purchase['vendor']}'),
              Text('Branch Name: ${purchase['branch']}\n'),
              Text('S.NO.  Articals  Quantity'),
              for (var item in purchase['items'])
                Text('${item['s_no']}  ${item['product']}  ${item['quantity']}'),
              SizedBox(height: 10),
              Text('Incharge: Principal: Director:'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Purchase No.')),
        DataColumn(label: Text('Branch')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Vendor')),
        DataColumn(label: Text('Total Amount')),
        DataColumn(label: Text('Gross Amount')),
        DataColumn(label: Text('Net Amount')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows: purchases
          .asMap()
          .map((index, purchase) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(purchase['purchase_no'])),
          DataCell(Text(purchase['branch'])),
          DataCell(Text(purchase['date'])),
          DataCell(Text(purchase['vendor'])),
          DataCell(Text(purchase['total_amount'].toString())),
          DataCell(Text(purchase['gross_amount'].toString())),
          DataCell(Text(purchase['net_amount'].toString())),
          DataCell(Text(purchase['status'])),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showEditPurchaseDialog(
                    purchase['id'],
                    purchase['branch'],
                    purchase['category'],
                    purchase['vendor'],
                    purchase['type'],
                    purchase['date'],
                    purchase['approver'],
                    purchase['product'],
                    purchase['quantity'],
                    purchase['price'],
                    purchase['unit'],
                    purchase['discount'],
                    purchase['gross'],
                    purchase['tax'],
                    purchase['net'],
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deletePurchase(purchase['id']);
                },
              ),
              IconButton(
                icon: Icon(Icons.receipt),
                onPressed: () {
                  _showReceiptDialog(purchase);
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
        title: Text('Purchase List'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: _showCreatePurchaseDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildPurchaseTable(),
        ),
      ),
    );
  }
}
