import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NoticeBoardScreen extends StatefulWidget {
  @override
  _NoticeBoardScreenState createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  List<dynamic> notices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    final url = Uri.parse('http://localhost:3000/notices');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          notices = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load notices');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch notices. Please try again.');
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

  void _showPostNoticeDialog() {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Post Notice'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 3,
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
            child: Text('Post'),
            onPressed: () {
              final title = _titleController.text;
              final content = _contentController.text;
              if (title.isNotEmpty && content.isNotEmpty) {
                _postNotice(title, content);
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

  Future<void> _postNotice(String title, String content) async {
    final url = Uri.parse('http://localhost:3000/notices');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'content': content}),
      );
      if (response.statusCode == 201) {
        _fetchNotices();
      } else {
        throw Exception('Failed to post notice');
      }
    } catch (error) {
      _showErrorDialog('Failed to post notice. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notice Board'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showPostNoticeDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notices.length,
        itemBuilder: (ctx, index) {
          final notice = notices[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(notice['title']),
              subtitle: Text(notice['content']),
              trailing: Text(
                notice['date_posted'].split('T').first,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
