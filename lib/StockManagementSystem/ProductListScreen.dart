import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final url = Uri.parse('http://localhost:3000/products');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch products. Please try again.');
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

  void _showCreateProductDialog() {
    final _productNameController = TextEditingController();
    final _quantityController = TextEditingController();
    final _productUnitController = TextEditingController();
    final _productCodeController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _vendorNameController = TextEditingController();
    final _vendorPriceController = TextEditingController();
    final _discountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _productUnitController,
                decoration: InputDecoration(labelText: 'Product Unit'),
              ),
              TextField(
                controller: _productCodeController,
                decoration: InputDecoration(labelText: 'Product Code'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _vendorNameController,
                decoration: InputDecoration(labelText: 'Vendor Name'),
              ),
              TextField(
                controller: _vendorPriceController,
                decoration: InputDecoration(labelText: 'Vendor Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _discountController,
                decoration: InputDecoration(labelText: 'Discount'),
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
              final productName = _productNameController.text;
              final quantity = _quantityController.text;
              final productUnit = _productUnitController.text;
              final productCode = _productCodeController.text;
              final description = _descriptionController.text;
              final vendorName = _vendorNameController.text;
              final vendorPrice = _vendorPriceController.text;
              final discount = _discountController.text;

              if (productName.isNotEmpty &&
                  quantity.isNotEmpty &&
                  productUnit.isNotEmpty &&
                  productCode.isNotEmpty &&
                  description.isNotEmpty &&
                  vendorName.isNotEmpty &&
                  vendorPrice.isNotEmpty &&
                  discount.isNotEmpty) {
                _createProduct(productName, int.parse(quantity), productUnit, productCode, description, vendorName, double.parse(vendorPrice), double.parse(discount));
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

  void _createProduct(String productName, int quantity, String productUnit, String productCode, String description, String vendorName, double vendorPrice, double discount) async {
    final url = Uri.parse('http://localhost:3000/products');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'product_name': productName,
          'quantity': quantity,
          'product_unit': productUnit,
          'product_code': productCode,
          'description': description,
          'vendor_name': vendorName,
          'vendor_price': vendorPrice,
          'discount': discount,
        }),
      );
      if (response.statusCode == 201) {
        _fetchProducts();
      } else {
        throw Exception('Failed to create product');
      }
    } catch (error) {
      _showErrorDialog('Failed to create product. Please try again.');
    }
  }

  void _showEditProductDialog(int productId, String productName, int quantity, String productUnit, String productCode, String description, String vendorName, double vendorPrice, double discount) {
    final _productNameController = TextEditingController(text: productName);
    final _quantityController = TextEditingController(text: quantity.toString());
    final _productUnitController = TextEditingController(text: productUnit);
    final _productCodeController = TextEditingController(text: productCode);
    final _descriptionController = TextEditingController(text: description);
    final _vendorNameController = TextEditingController(text: vendorName);
    final _vendorPriceController = TextEditingController(text: vendorPrice.toString());
    final _discountController = TextEditingController(text: discount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _productNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _productUnitController,
                decoration: InputDecoration(labelText: 'Product Unit'),
              ),
              TextField(
                controller: _productCodeController,
                decoration: InputDecoration(labelText: 'Product Code'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _vendorNameController,
                decoration: InputDecoration(labelText: 'Vendor Name'),
              ),
              TextField(
                controller: _vendorPriceController,
                decoration: InputDecoration(labelText: 'Vendor Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _discountController,
                decoration: InputDecoration(labelText: 'Discount'),
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
              final newProductName = _productNameController.text;
              final newQuantity = int.parse(_quantityController.text);
              final newProductUnit = _productUnitController.text;
              final newProductCode = _productCodeController.text;
              final newDescription = _descriptionController.text;
              final newVendorName = _vendorNameController.text;
              final newVendorPrice = double.parse(_vendorPriceController.text);
              final newDiscount = double.parse(_discountController.text);

              if (newProductName.isNotEmpty &&
                  newQuantity > 0 &&
                  newProductUnit.isNotEmpty &&
                  newProductCode.isNotEmpty &&
                  newDescription.isNotEmpty &&
                  newVendorName.isNotEmpty &&
                  newVendorPrice >= 0 &&
                  newDiscount >= 0) {
                _updateProduct(productId, newProductName, newQuantity, newProductUnit, newProductCode, newDescription, newVendorName, newVendorPrice, newDiscount);
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

  void _updateProduct(int productId, String productName, int quantity, String productUnit, String productCode, String description, String vendorName, double vendorPrice, double discount) async {
    final url = Uri.parse('http://localhost:3000/products/$productId');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'product_name': productName,
          'quantity': quantity,
          'product_unit': productUnit,
          'product_code': productCode,
          'description': description,
          'vendor_name': vendorName,
          'vendor_price': vendorPrice,
          'discount': discount,
        }),
      );
      if (response.statusCode == 200) {
        _fetchProducts();
      } else {
        throw Exception('Failed to update product');
      }
    } catch (error) {
      _showErrorDialog('Failed to update product. Please try again.');
    }
  }

  void _deleteProduct(int productId) async {
    final url = Uri.parse('http://localhost:3000/products/$productId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchProducts();
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete product. Please try again.');
    }
  }

  Widget _buildProductCard(product) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(product['product_name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity: ${product['quantity']}'),
            Text('Unit: ${product['product_unit']}'),
            Text('Vendor: ${product['vendor_name']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(FontAwesomeIcons.edit),
              onPressed: () {
                _showEditProductDialog(
                  product['product_id'],
                  product['product_name'],
                  product['quantity'],
                  product['product_unit'],
                  product['product_code'],
                  product['description'],
                  product['vendor_name'],
                  product['vendor_price'],
                  product['discount'],
                );
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.trashAlt),
              onPressed: () {
                _deleteProduct(product['product_id']);
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
        title: Text('Product List'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: _showCreateProductDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (ctx, index) {
          final product = products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }
}
