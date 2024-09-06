import 'package:flutter/material.dart';

class AdmissionConfirmedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text('Admission Confirmed'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admission Confirmed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            SizedBox(height: 20),
            Text(
              'Congratulations! Your admission is confirmed. Welcome to our school.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to further instructions or home screen
                },
                child: Text('Proceed to Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
