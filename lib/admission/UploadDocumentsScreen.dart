import 'package:flutter/material.dart';

class UploadDocumentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text('Upload Documents'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Required Documents',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            ),
            SizedBox(height: 20),
            _buildUploadButton('Upload Photo'),
            _buildUploadButton('Upload Aadhaar Card'),
            _buildUploadButton('Upload Marksheet'),
            _buildUploadButton('Upload Transfer Certificate'),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Upload document logic here
        },
        icon: Icon(Icons.upload_file),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
        ),
      ),
    );
  }
}
