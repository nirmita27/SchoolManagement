import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _allInfo = [
    "Approval Process for Teachers and Accountants",
    "How to Login",
    "How to Sign Up",
    "Forgot Password",
    "Change Password",
    "Update Profile",
    "Contact Us"
  ];
  List<String>? _filteredInfo;

  @override
  void initState() {
    super.initState();
    _filteredInfo = _allInfo;
  }

  void _filterInfo(String query) {
    setState(() {
      _filteredInfo = _allInfo
          .where((info) => info.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help Section"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.search, color: Colors.deepPurple),
              ),
              onChanged: (query) => _filterInfo(query),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: _filteredInfo!.map((info) {
                  return Card(
                    elevation: 5,
                    child: ExpansionTile(
                      title: Text(
                        info,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      children: [_getHelpContent(info)],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            _buildContactList(),
          ],
        ),
      ),
    );
  }

  Widget _getHelpContent(String title) {
    switch (title) {
      case "Approval Process for Teachers and Accountants":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "To request approval as a teacher or accountant, please follow these steps:\n"
                "1. Navigate to the approval section in the app.\n"
                "2. Fill in all required details.\n"
                "3. Submit your request.\n"
                "4. The admin will review your request.\n"
                "5. You will be notified via email once a decision is made.",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      case "How to Login":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "To login, enter your username and password on the login screen and press the login button. If you encounter any issues, please contact support.",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      case "How to Sign Up":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "To sign up, click on the 'Sign Up' button on the login screen, fill in the required details, and submit the form. You will receive a confirmation email.",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      case "Forgot Password":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "If you forgot your password, click on the 'Forgot Password' link on the login screen. Enter your registered email address, and we will send you instructions to reset your password.",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      case "Change Password":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "To change your password, go to the profile settings, select 'Change Password', enter your current password, then enter and confirm your new password.",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      case "Update Profile":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "To update your profile, go to the profile settings, make the necessary changes, and save your updates.",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      case "Contact Us":
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "If you have any queries, please contact us at:\n"
                "Phone: +1 234 567 890\n"
                "Email: support@school.com\n"
                "Address: 123 School St, City, Country",
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildContactList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Contact Us",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        ListTile(
          leading: Icon(Icons.phone, color: Colors.white),
          title: Text("Office Phone: +1 234 567 890", style: TextStyle(color: Colors.white)),
        ),
        ListTile(
          leading: Icon(Icons.email, color: Colors.white),
          title: Text("Email: info@school.com", style: TextStyle(color: Colors.white)),
        ),
        ListTile(
          leading: Icon(Icons.location_on, color: Colors.white),
          title: Text("Address: 123 School St, City, Country", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}