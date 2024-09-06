import 'package:flutter/material.dart';

class DocumentVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text('Document Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            ),
            SizedBox(height: 20),
            Text(
              'Your documents are being verified. You will be notified once the verification is complete.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
