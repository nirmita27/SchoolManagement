import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:school_management/StaffManagement/DesignationMasterScreen.dart';
import 'package:school_management/StaffManagement/ReleasedStaffListScreen.dart';
import 'package:school_management/StaffManagement/StaffCategoryMasterScreen.dart';
import 'package:school_management/StaffManagement/StaffListScreen.dart';

import 'DepartmentMasterScreen.dart';

class StaffManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STAFF MANAGEMENT'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade200],
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
                    color: Colors.black,
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
                    color: Colors.black,
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
            'Staff List',
            Icons.list,
            StaffListScreen(),
          ),
          SizedBox(width: 16),
          _buildModuleButton(
            context,
            'Staff List (Released)',
            Icons.list_alt,
            ReleasedStaffListScreen(),
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
            'Department Master',
            Icons.business,
            DepartmentMasterScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Designation Master',
            Icons.badge,
            DesignationMasterScreen(),
          ),
          SizedBox(width: 10),
          _buildModuleButton(
            context,
            'Staff Category Master',
            Icons.category,
            StaffCategoryMasterScreen(),
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
              colors: [Colors.white, Colors.greenAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.deepPurpleAccent),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
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

class DummyScreen extends StatelessWidget {
  final String title;

  DummyScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
