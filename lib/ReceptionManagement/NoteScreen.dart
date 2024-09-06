import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<dynamic> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final url = Uri.parse('http://localhost:3000/notes');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          notes = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch notes. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? note}) {
    final _noteController = TextEditingController(text: note?['note_message']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Note'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text(note == null ? 'Add' : 'Save'),
            onPressed: () {
              final noteMessage = _noteController.text;

              if (note == null) {
                _createNote(noteMessage);
              } else {
                _editNote(note['id'], noteMessage);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createNote(String noteMessage) async {
    final url = Uri.parse('http://localhost:3000/notes');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'note_message': noteMessage}),
      );
      if (response.statusCode == 201) {
        _fetchNotes();
      } else {
        throw Exception('Failed to create note');
      }
    } catch (error) {
      _showErrorDialog('Failed to create note. Please try again.');
    }
  }

  void _editNote(int id, String noteMessage) async {
    final url = Uri.parse('http://localhost:3000/notes/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'note_message': noteMessage}),
      );
      if (response.statusCode == 200) {
        _fetchNotes();
      } else {
        throw Exception('Failed to edit note');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit note. Please try again.');
    }
  }

  void _deleteNote(int id) async {
    final url = Uri.parse('http://localhost:3000/notes/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchNotes();
      } else {
        throw Exception('Failed to delete note');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete note. Please try again.');
    }
  }

  Widget _buildNoteTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Note Message')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Actions')),
      ],
      rows: notes
          .asMap()
          .map((index, note) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(note['note_message'] ?? '')),
          DataCell(Text(note['date'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(note: note);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteNote(note['id']);
                },
              ),
            ],
          )),
        ]),
      ))
          .values
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note List'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildNoteTable(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateEditDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}
