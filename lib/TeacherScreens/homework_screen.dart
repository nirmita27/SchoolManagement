import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeworkScreen extends StatefulWidget {
  @override
  _HomeworkScreenState createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  List<dynamic> homeworkList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomework();
  }

  Future<void> _fetchHomework() async {
    final url = Uri.parse('http://localhost:3000/homework');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          homeworkList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load homework');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch homework. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _approveHomework(int homeworkId) async {
    final url = Uri.parse('http://localhost:3000/homework/approve/$homeworkId');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        _fetchHomework();
      } else {
        throw Exception('Failed to approve homework');
      }
    } catch (error) {
      _showErrorDialog('Failed to approve homework. Please try again.');
    }
  }

  void _assignHomework(String title, String description) async {
    final url = Uri.parse('http://localhost:3000/homework');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'description': description}),
      );
      if (response.statusCode == 201) {
        _fetchHomework();
      } else {
        throw Exception('Failed to assign homework');
      }
    } catch (error) {
      _showErrorDialog('Failed to assign homework. Please try again.');
    }
  }

  void _showAssignHomeworkDialog() {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Homework'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
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
            child: Text('Assign'),
            onPressed: () {
              final title = _titleController.text;
              final description = _descriptionController.text;
              if (title.isNotEmpty && description.isNotEmpty) {
                _assignHomework(title, description);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _showHomeworkDetailsDialog(dynamic homework) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(homework['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Description: ${homework['description']}'),
            SizedBox(height: 10),
            Text('Status: ${homework['status']}'),
            SizedBox(height: 10),
            Text('Created At: ${homework['created_at']}'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showEditHomeworkDialog(dynamic homework) {
    final _titleController = TextEditingController(text: homework['title']);
    final _descriptionController = TextEditingController(text: homework['description']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Homework'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
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
            child: Text('Save'),
            onPressed: () {
              final title = _titleController.text;
              final description = _descriptionController.text;
              if (title.isNotEmpty && description.isNotEmpty) {
                _updateHomework(homework['id'], title, description);
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateHomework(int id, String title, String description) async {
    final url = Uri.parse('http://localhost:3000/homework/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'description': description}),
      );
      if (response.statusCode == 200) {
        _fetchHomework();
      } else {
        throw Exception('Failed to update homework');
      }
    } catch (error) {
      _showErrorDialog('Failed to update homework. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homework'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAssignHomeworkDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: homeworkList.length,
        itemBuilder: (ctx, index) {
          final homework = homeworkList[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(homework['title']),
              subtitle: Text(homework['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  homework['status'] == 'pending'
                      ? IconButton(
                    icon: Icon(Icons.check),
                    color: Colors.green,
                    onPressed: () => _approveHomework(homework['id']),
                  )
                      : Icon(Icons.check, color: Colors.grey),
                  IconButton(
                    icon: Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () => _showEditHomeworkDialog(homework),
                  ),
                  IconButton(
                    icon: Icon(Icons.info),
                    color: Colors.orange,
                    onPressed: () => _showHomeworkDetailsDialog(homework),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
