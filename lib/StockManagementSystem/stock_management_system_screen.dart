import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'ApproveOrderScreen.dart';
import 'IssueProductListScreen.dart';
import 'ProductListScreen.dart';
import 'ProductScrapListScreen.dart';
import 'ProductUnitScreen.dart';
import 'PurchaseListScreen.dart';
import 'SetPaymentReminderScreen.dart';
import 'StockCategoryScreen.dart';
import 'StockMovementScreen.dart';
import 'StockTypeScreen.dart';
import 'VendorScreen.dart';

class StockManagementSystem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STOCK MANAGEMENT'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.greenAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'MODULES',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(3, 3),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildModuleRow(context),
                SizedBox(height: 30),
                Text(
                  'MASTER SETTINGS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black26,
                        offset: Offset(3, 3),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildSettingsRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildModuleButton(
            context,
            'Issue Product List',
            Icons.list_alt,
            IssueProductListScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Product Scrap List',
            Icons.delete,
            ProductScrapListScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Stock Movement',
            Icons.compare_arrows,
            StockMovementScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Purchase List',
            Icons.shopping_cart,
            PurchaseListScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Approve Order',
            Icons.check,
            ApproveOrderScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Set Payment Reminder',
            Icons.alarm,
            SetPaymentReminderScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildModuleButton(
            context,
            'Product Unit',
            Icons.straighten,
            ProductUnitScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Product List',
            Icons.list,
            ProductListScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Stock Category',
            Icons.category,
            StockCategoryScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Stock Type',
            Icons.layers,
            StockTypeScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Vendor',
            Icons.business,
            VendorScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleButton(BuildContext context, String title, IconData icon, Widget screen) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (context, _) => screen,
      closedElevation: 10,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      closedColor: Colors.white,
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.white, Colors.teal.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.teal),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

