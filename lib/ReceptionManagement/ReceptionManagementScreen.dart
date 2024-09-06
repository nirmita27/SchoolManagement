import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'DaakDispatchedScreen.dart';
import 'DaakReceivedScreen.dart';
import 'EmailRecordScreen.dart';
import 'InchargeListScreen.dart';
import 'IncomingCallScreen.dart';
import 'NoteScreen.dart';
import 'OutgoingCallScreen.dart';
import 'ParentRequestScreen.dart';
import 'WalkInRecordsScreen.dart';

class ReceptionManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          'Reception Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
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
                'Note',
                FontAwesomeIcons.stickyNote,
                NoteScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Walk In Records',
                FontAwesomeIcons.walking,
                WalkInRecordsScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Parent Request',
                FontAwesomeIcons.userFriends,
                ParentRequestScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Daak Received',
                FontAwesomeIcons.inbox,
                DaakReceivedScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Daak Dispatch',
                FontAwesomeIcons.truck,
                DaakDispatchedScreen(),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModuleButton(
                context,
                'Incoming Call',
                FontAwesomeIcons.phone,
                IncomingCallScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Outgoing Call',
                FontAwesomeIcons.phoneAlt,
                OutgoingCallScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Email Record',
                FontAwesomeIcons.envelope,
                EmailRecordScreen(),
              ),
              SizedBox(width: 10),
              _buildModuleButton(
                context,
                'Incharge List',
                FontAwesomeIcons.userShield,
                InchargeListScreen(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModuleButton(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.purple[50]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.deepPurpleAccent),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}