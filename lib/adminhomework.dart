import 'package:flutter/material.dart';

class HomeworkPage extends StatelessWidget {
  void _showHomeworkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Homework'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('Upload Homework'),
              onTap: () {
                // Add your functionality here
              },
            ),
            ListTile(
              title: Text('Approve Homework'),
              onTap: () {
                // Add your functionality here
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homework Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showHomeworkDialog(context),
          child: Text('Homework'),
        ),
      ),
    );
  }
}