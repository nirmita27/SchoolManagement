import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_management/LeaveManagement/AppliedLeaveScreen.dart';

import 'ApproveStaffLeaveScreen.dart';
import 'ApproveStudentLeaveScreen.dart';
import 'LeaveApproverMasterScreen.dart';
import 'LeaveRulesMasterScreen.dart';
import 'LeaveTypeMasterScreen.dart';
import 'PermissionForOtherStaffScreen.dart';

class LeaveManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Management'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'MODULES',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                SizedBox(height: 20),
                _buildModuleRow(context),
                SizedBox(height: 40),
                Text(
                  'MASTER SETTINGS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
                SizedBox(height: 20),
                _buildMasterSettingsRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleRow(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModuleButton(
                context,
                'Applied Leave',
                FontAwesomeIcons.calendarCheck,
                LeaveListScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Approve Staff Leave',
                FontAwesomeIcons.userCheck,
                ApproveStaffLeaveScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Approve Student Leave',
                FontAwesomeIcons.userGraduate,
                ApproveStudentLeaveScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Permission for Other Staff(Leave)',
                FontAwesomeIcons.userPlus,
                PermissionForOtherStaffScreen(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMasterSettingsRow(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModuleButton(
                context,
                'Leave Type Master',
                FontAwesomeIcons.cogs,
                LeaveTypeMasterScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Leave Approve Master',
                FontAwesomeIcons.userCog,
                LeaveApproveMasterScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Leave Rules Master',
                FontAwesomeIcons.book,
                LeaveRulesMasterScreen(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModuleButton(BuildContext context, String title, IconData icon, Widget screen) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 40),
          SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}