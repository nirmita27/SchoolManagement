import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductScrapListScreen extends StatefulWidget {
  @override
  _ProductScrapListScreenState createState() => _ProductScrapListScreenState();
}

class _ProductScrapListScreenState extends State<ProductScrapListScreen> {
  List<dynamic> scrapProducts = [];
  List<dynamic> stockCategories = [];
  List<dynamic> stockTypes = [];
  List<dynamic> products = [];
  bool isLoading = true;
  bool isDropdownLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchScrapProducts();
    _fetchDropdownData();
  }

  Future<void> _fetchScrapProducts() async {
    final url = Uri.parse('http://localhost:3000/product-scrap');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          scrapProducts = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load scrap products');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch scrap products. Please try again.');
    }
  }

  Future<void> _fetchDropdownData() async {
    try {
      final categoriesResponse = await http.get(Uri.parse('http://localhost:3000/stock-categories'));
      final typesResponse = await http.get(Uri.parse('http://localhost:3000/stock-types'));
      final productsResponse = await http.get(Uri.parse('http://localhost:3000/products'));

      if (categoriesResponse.statusCode == 200 && typesResponse.statusCode == 200 && productsResponse.statusCode == 200) {
        setState(() {
          stockCategories = json.decode(categoriesResponse.body);
          stockTypes = json.decode(typesResponse.body);
          products = json.decode(productsResponse.body);
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

  void _showCreateScrapDialog() {
    final _categoryController = TextEditingController();
    final _typeController = TextEditingController();
    final _productController = TextEditingController();
    final _scrapController = TextEditingController();
    final _quantityController = TextEditingController();
    final _scrapDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Scrap Product'),
        content: SingleChildScrollView(
          child: isDropdownLoading
              ? CircularProgressIndicator()
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                items: stockTypes.map<DropdownMenuItem<String>>((type) {
                  return DropdownMenuItem<String>(
                    value: type['type_name'],
                    child: Text(type['type_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Type'),
                onChanged: (value) {
                  _typeController.text = value.toString();
                },
              ),
              DropdownButtonFormField(
                items: products.map<DropdownMenuItem<String>>((product) {
                  return DropdownMenuItem<String>(
                    value: product['product_name'],
                    child: Text(product['product_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Product'),
                onChanged: (value) {
                  _productController.text = value.toString();
                },
              ),
              TextField(
                controller: _scrapController,
                decoration: InputDecoration(labelText: 'Scrap'),
              ),
              TextField(
                controller: _scrapDateController,
                decoration: InputDecoration(labelText: 'Scrap Date'),
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
              final category = _categoryController.text;
              final type = _typeController.text;
              final product = _productController.text;
              final scrap = _scrapController.text;
              final scrapDate = _scrapDateController.text;
              final quantity = _quantityController.text;

              if (category.isNotEmpty &&
                  type.isNotEmpty &&
                  product.isNotEmpty &&
                  scrap.isNotEmpty &&
                  scrapDate.isNotEmpty &&
                  quantity.isNotEmpty) {
                _createScrapProduct(category, type, product, scrap, int.parse(quantity), scrapDate);
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

  void _createScrapProduct(String category, String type, String product, String scrap, int quantity, String scrapDate) async {
    final url = Uri.parse('http://localhost:3000/product-scrap');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'category': category,
          'type': type,
          'product': product,
          'scrap': scrap,
          'quantity': quantity,
          'scrap_date': scrapDate,
        }),
      );
      if (response.statusCode == 201) {
        _fetchScrapProducts();
      } else {
        throw Exception('Failed to create scrap product');
      }
    } catch (error) {
      _showErrorDialog('Failed to create scrap product. Please try again.');
    }
  }

  Widget _buildScrapDataTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Product')),
        DataColumn(label: Text('Scrap')),
        DataColumn(label: Text('Quantity')),
        DataColumn(label: Text('Scrap Date')),
      ],
      rows: scrapProducts
          .asMap()
          .map((index, scrap) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(scrap['product'])),
          DataCell(Text(scrap['scrap'])),
          DataCell(Text(scrap['quantity'].toString())),
          DataCell(Text(scrap['scrap_date'])),
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
        title: Text('Scrap Product List'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: _showCreateScrapDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildScrapDataTable(),
        ),
      ),
    );
  }
}
