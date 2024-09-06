import 'package:flutter/material.dart';

class LibraryManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Library Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildDrawerItem(context, 'Issue Book', Icons.book, '/issuedBooks'),
            _buildDrawerItem(context, 'Receive Book', Icons.bookmark, '/receiveBook'),
            _buildDrawerItem(context, 'Scrap a Book', Icons.delete_forever, '/scrapBook'),
            _buildDrawerItem(context, 'Check Availability', Icons.search, '/checkAvailability'),
            _buildDrawerItem(context, 'Library Records', Icons.list, '/studentLibraryRecord'),
            _buildDrawerItem(context, 'Track Fines', Icons.attach_money, '/trackFines'),
            _buildDrawerItem(context, 'Monthly Issued Report', Icons.calendar_today, '/monthlyIssuedReport'),
            _buildDrawerItem(context, 'Stock Report', Icons.inventory, '/stockReport'),
            _buildDrawerItem(context, 'Top User Report', Icons.star, '/topUserReport'),
            _buildDrawerItem(context, 'Staff Consolidation Report', Icons.group, '/staffConsolidationReport'),
            _buildDrawerItem(context, 'Sub Category Master', Icons.category, '/subCategoryMaster'),
            _buildDrawerItem(context, 'Book Master', Icons.book_online, '/bookMaster'),
            _buildDrawerItem(context, 'Category Master', Icons.category, '/categoryMaster'),
            _buildDrawerItem(context, 'Book Publisher', Icons.publish, '/bookPublisher'),
          ],
        ),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_library,
            size: 100,
            color: Colors.teal,
          ),
          SizedBox(height: 20),
          Text(
            'Welcome to the Library Management System',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Use the navigation drawer to manage your library activities efficiently.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> libraryItems = [
  {
    'title': 'Issue Book',
    'icon': Icons.book,
    'route': '/issuedBooks',
  },
  {
    'title': 'Receive Book',
    'icon': Icons.bookmark,
    'route': '/receiveBook',
  },
  {
    'title': 'Scrap a Book',
    'icon': Icons.delete_forever,
    'route': '/scrapBook',
  },
  {
    'title': 'Check Availability',
    'icon': Icons.search,
    'route': '/checkAvailability',
  },
  {
    'title': 'Library Records',
    'icon': Icons.list,
    'route': '/studentLibraryRecord',
  },
  {
    'title': 'Track Fines',
    'icon': Icons.attach_money,
    'route': '/trackFines',
  },
  {
    'title': 'Monthly Issued Report',
    'icon': Icons.calendar_today,
    'route': '/monthlyIssuedReport',
  },
  {
    'title': 'Stock Report',
    'icon': Icons.inventory,
    'route': '/stockReport',
  },
  {
    'title': 'Top User Report',
    'icon': Icons.star,
    'route': '/topUserReport',
  },
  {
    'title': 'Staff Consolidation Report',
    'icon': Icons.group,
    'route': '/staffConsolidationReport',
  },
  {
    'title': 'Sub Category Master',
    'icon': Icons.category,
    'route': '/subCategoryMaster',
  },
  {
    'title': 'Book Master',
    'icon': Icons.book_online,
    'route': '/bookMaster',
  },
  {
    'title': 'Category Master',
    'icon': Icons.category,
    'route': '/categoryMaster',
  },
  {
    'title': 'Book Publisher',
    'icon': Icons.publish,
    'route': '/bookPublisher',
  },
];
