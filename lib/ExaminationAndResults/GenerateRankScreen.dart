import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GenerateRankScreen extends StatefulWidget {
  @override
  _GenerateRankScreenState createState() => _GenerateRankScreenState();
}

class _GenerateRankScreenState extends State<GenerateRankScreen> {
  List<String> classSections = [];
  List<dynamic> designs = [];
  String? selectedClassSection;
  dynamic selectedDesign;

  @override
  void initState() {
    super.initState();
    fetchClassSections();
    fetchDesigns();
  }

  Future<void> fetchClassSections() async {
    try {
      var response = await http.get(Uri.parse('http://localhost:3000/class-sections'));
      if (response.statusCode == 200) {
        setState(() {
          classSections = List<String>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load class sections');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchDesigns() async {
    try {
      var response = await http.get(Uri.parse('http://localhost:3000/designs'));
      if (response.statusCode == 200) {
        setState(() {
          designs = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load designs');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generate Student Rank"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DropdownButton<String>(
            hint: Text("Select Class & Section"),
            value: selectedClassSection,
            onChanged: (newValue) {
              setState(() {
                selectedClassSection = newValue;
              });
            },
            items: classSections.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          DropdownButton<dynamic>(
            hint: Text("Select Design"),
            value: selectedDesign,
            onChanged: (newValue) {
              setState(() {
                selectedDesign = newValue;
              });
            },
            items: designs.map<DropdownMenuItem<dynamic>>((design) {
              return DropdownMenuItem<dynamic>(
                value: design,
                child: Text(design['name']),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: generateRank,
            child: Text('Generate Rank'),
          ),
        ],
      ),
    );
  }

  Future<void> generateRank() async {
    if (selectedClassSection == null || selectedDesign == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Error"),
          content: Text("Please select both a class section and a design."),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('http://localhost:3000/generate-rank'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'classSection': selectedClassSection,
          'designId': selectedDesign['id'],
        }),
      );

      if (response.statusCode == 200) {
        // Assuming the response contains the rank data
        final results = json.decode(response.body);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Rank Generated Successfully"),
            content: Text("Results: ${results.toString()}"),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to generate rank.');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to generate rank: ${e.toString()}"),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    }
  }

}
