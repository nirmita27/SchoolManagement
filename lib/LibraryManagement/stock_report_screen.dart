import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockReportScreen extends StatefulWidget {
  @override
  _StockReportScreenState createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  List stockReport = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStockReport();
  }

  Future<void> _fetchStockReport() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/stock_report?search=$searchQuery'));
      if (response.statusCode == 200) {
        setState(() {
          stockReport = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load stock report');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _fetchStockReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Report'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Report',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : stockReport.isEmpty
                ? Center(child: Text('No Records Found.'))
                : ListView.builder(
              itemCount: stockReport.length,
              itemBuilder: (context, index) {
                final report = stockReport[index];
                return Card(
                  child: ListTile(
                    title: Text(report['book_category_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Books: ${report['total_books']}'),
                        Text('Total Quantity: ${report['total_quantity']}'),
                        Text('Issued Books: ${report['issued_books']}'),
                        Text('Available Books: ${report['available_books']}'),
                        Text('Location: ${report['location']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
