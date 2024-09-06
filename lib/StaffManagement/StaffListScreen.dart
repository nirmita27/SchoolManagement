import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class StaffListScreen extends StatefulWidget {
  @override
  _StaffListScreenState createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  List<dynamic> staffList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStaffList();
  }

  Future<void> _fetchStaffList() async {
    final url = Uri.parse('http://localhost:3000/staff');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          staffList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load staff list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch staff list. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? staff}) {
    final _titleController = TextEditingController(text: staff?['title']);
    final _nameController = TextEditingController(text: staff?['name']);
    final _educationController = TextEditingController(text: staff?['education']);
    final _dobController = TextEditingController(text: staff?['date_of_birth']);
    final _bloodGroupController = TextEditingController(text: staff?['blood_group']);
    final _genderController = TextEditingController(text: staff?['gender']);
    final _religionController = TextEditingController(text: staff?['religion']);
    final _maritalStatusController = TextEditingController(text: staff?['marital_status']);
    final _domController = TextEditingController(text: staff?['date_of_marriage']);
    final _fatherHusbandNameController = TextEditingController(text: staff?['father_husband_name']);
    final _isTeachingEmployeeController = TextEditingController(text: staff?['is_teaching_employee'].toString());
    final _identityProofTypeController = TextEditingController(text: staff?['identity_proof_type']);
    final _emergencyContactNoController = TextEditingController(text: staff?['emergency_contact_no']);
    final _workingExperienceController = TextEditingController(text: staff?['working_experience']);
    final _dojController = TextEditingController(text: staff?['date_of_joining']);
    final _aadharCardNoController = TextEditingController(text: staff?['aadhar_card_no']);
    final _panCardNoController = TextEditingController(text: staff?['pan_card_no']);
    final _branchController = TextEditingController(text: staff?['branch']);
    final _mobileNoController = TextEditingController(text: staff?['mobile_no']);
    final _emailController = TextEditingController(text: staff?['email']);
    final _addressController = TextEditingController(text: staff?['address']);
    final _departmentController = TextEditingController(text: staff?['department']);
    final _designationController = TextEditingController(text: staff?['designation']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(staff == null ? 'Add New Staff' : 'Edit Staff'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Personal Info
              TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Title')),
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
              TextField(controller: _educationController, decoration: InputDecoration(labelText: 'Education')),
              TextField(controller: _dobController, decoration: InputDecoration(labelText: 'Date of Birth')),
              TextField(controller: _bloodGroupController, decoration: InputDecoration(labelText: 'Blood Group')),
              TextField(controller: _genderController, decoration: InputDecoration(labelText: 'Gender')),
              TextField(controller: _religionController, decoration: InputDecoration(labelText: 'Religion')),
              TextField(controller: _maritalStatusController, decoration: InputDecoration(labelText: 'Marital Status')),
              TextField(controller: _domController, decoration: InputDecoration(labelText: 'Date of Marriage')),
              TextField(controller: _fatherHusbandNameController, decoration: InputDecoration(labelText: 'Father/Husband Name')),
              TextField(controller: _isTeachingEmployeeController, decoration: InputDecoration(labelText: 'Is Teaching Employee')),
              TextField(controller: _identityProofTypeController, decoration: InputDecoration(labelText: 'Identity Proof Type')),
              TextField(controller: _emergencyContactNoController, decoration: InputDecoration(labelText: 'Emergency Contact No')),
              TextField(controller: _workingExperienceController, decoration: InputDecoration(labelText: 'Working Experience')),
              TextField(controller: _dojController, decoration: InputDecoration(labelText: 'Date of Joining')),
              TextField(controller: _aadharCardNoController, decoration: InputDecoration(labelText: 'Aadhar Card No')),
              TextField(controller: _panCardNoController, decoration: InputDecoration(labelText: 'Pan Card No')),
              TextField(controller: _branchController, decoration: InputDecoration(labelText: 'Branch')),
              // Contact Info
              TextField(controller: _mobileNoController, decoration: InputDecoration(labelText: 'Mobile No')),
              TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: _addressController, decoration: InputDecoration(labelText: 'Address')),
              // Credential Info
              TextField(controller: _departmentController, decoration: InputDecoration(labelText: 'Department')),
              TextField(controller: _designationController, decoration: InputDecoration(labelText: 'Designation')),
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
            child: Text(staff == null ? 'Add' : 'Save'),
            onPressed: () {
              final title = _titleController.text;
              final name = _nameController.text;
              final education = _educationController.text;
              final dateOfBirth = _dobController.text;
              final bloodGroup = _bloodGroupController.text;
              final gender = _genderController.text;
              final religion = _religionController.text;
              final maritalStatus = _maritalStatusController.text;
              final dateOfMarriage = _domController.text;
              final fatherHusbandName = _fatherHusbandNameController.text;
              final isTeachingEmployee = _isTeachingEmployeeController.text == 'true';
              final identityProofType = _identityProofTypeController.text;
              final emergencyContactNo = _emergencyContactNoController.text;
              final workingExperience = _workingExperienceController.text;
              final dateOfJoining = _dojController.text;
              final aadharCardNo = _aadharCardNoController.text;
              final panCardNo = _panCardNoController.text;
              final branch = _branchController.text;
              final mobileNo = _mobileNoController.text;
              final email = _emailController.text;
              final address = _addressController.text;
              final department = _departmentController.text;
              final designation = _designationController.text;

              if (staff == null) {
                _createStaff(
                    title, name, education, dateOfBirth, bloodGroup, gender, religion, maritalStatus,
                    dateOfMarriage, fatherHusbandName, isTeachingEmployee, identityProofType, emergencyContactNo,
                    workingExperience, dateOfJoining, aadharCardNo, panCardNo, branch, mobileNo, email,
                    address, department, designation
                );
              } else {
                _editStaff(
                    staff['id'], title, name, education, dateOfBirth, bloodGroup, gender, religion, maritalStatus,
                    dateOfMarriage, fatherHusbandName, isTeachingEmployee, identityProofType, emergencyContactNo,
                    workingExperience, dateOfJoining, aadharCardNo, panCardNo, branch, mobileNo, email,
                    address, department, designation
                );
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createStaff(
      String title, String name, String education, String dateOfBirth, String bloodGroup, String gender, String religion,
      String maritalStatus, String dateOfMarriage, String fatherHusbandName, bool isTeachingEmployee, String identityProofType,
      String emergencyContactNo, String workingExperience, String dateOfJoining, String aadharCardNo, String panCardNo,
      String branch, String mobileNo, String email, String address, String department, String designation
      ) async {
    final url = Uri.parse('http://localhost:3000/staff');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'name': name,
          'education': education,
          'date_of_birth': dateOfBirth,
          'blood_group': bloodGroup,
          'gender': gender,
          'religion': religion,
          'marital_status': maritalStatus,
          'date_of_marriage': dateOfMarriage,
          'father_husband_name': fatherHusbandName,
          'is_teaching_employee': isTeachingEmployee,
          'identity_proof_type': identityProofType,
          'emergency_contact_no': emergencyContactNo,
          'working_experience': workingExperience,
          'date_of_joining': dateOfJoining,
          'aadhar_card_no': aadharCardNo,
          'pan_card_no': panCardNo,
          'branch': branch,
          'mobile_no': mobileNo,
          'email': email,
          'address': address,
          'department': department,
          'designation': designation,
        }),
      );
      if (response.statusCode == 201) {
        _fetchStaffList();
      } else {
        throw Exception('Failed to create staff');
      }
    } catch (error) {
      _showErrorDialog('Failed to create staff. Please try again.');
    }
  }

  void _editStaff(
      int id, String title, String name, String education, String dateOfBirth, String bloodGroup, String gender, String religion,
      String maritalStatus, String dateOfMarriage, String fatherHusbandName, bool isTeachingEmployee, String identityProofType,
      String emergencyContactNo, String workingExperience, String dateOfJoining, String aadharCardNo, String panCardNo,
      String branch, String mobileNo, String email, String address, String department, String designation
      ) async {
    final url = Uri.parse('http://localhost:3000/staff/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'name': name,
          'education': education,
          'date_of_birth': dateOfBirth,
          'blood_group': bloodGroup,
          'gender': gender,
          'religion': religion,
          'marital_status': maritalStatus,
          'date_of_marriage': dateOfMarriage,
          'father_husband_name': fatherHusbandName,
          'is_teaching_employee': isTeachingEmployee,
          'identity_proof_type': identityProofType,
          'emergency_contact_no': emergencyContactNo,
          'working_experience': workingExperience,
          'date_of_joining': dateOfJoining,
          'aadhar_card_no': aadharCardNo,
          'pan_card_no': panCardNo,
          'branch': branch,
          'mobile_no': mobileNo,
          'email': email,
          'address': address,
          'department': department,
          'designation': designation,
        }),
      );
      if (response.statusCode == 200) {
        _fetchStaffList();
      } else {
        throw Exception('Failed to edit staff');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit staff. Please try again.');
    }
  }

  void _deleteStaff(int id) async {
    final url = Uri.parse('http://localhost:3000/staff/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchStaffList();
      } else {
        throw Exception('Failed to delete staff');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete staff. Please try again.');
    }
  }

  Future<void> _bulkUploadStaff() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final url = Uri.parse('http://localhost:3000/staff/bulk-upload');
      try {
        var request = http.MultipartRequest('POST', url);
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        var response = await request.send();
        if (response.statusCode == 200) {
          _fetchStaffList();
        } else {
          throw Exception('Failed to bulk upload staff');
        }
      } catch (error) {
        _showErrorDialog('Failed to bulk upload staff. Please try again.');
      }
    }
  }

  Future<void> _bulkUploadStaffImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final url = Uri.parse('http://localhost:3000/staff/bulk-upload-images');
      try {
        var request = http.MultipartRequest('POST', url);
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        var response = await request.send();
        if (response.statusCode == 200) {
          _fetchStaffList();
        } else {
          throw Exception('Failed to bulk upload staff images');
        }
      } catch (error) {
        _showErrorDialog('Failed to bulk upload staff images. Please try again.');
      }
    }
  }

  Widget _buildStaffTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Employee No./Staff No.')),
        DataColumn(label: Text('Mobile No')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Address')),
        DataColumn(label: Text('Department')),
        DataColumn(label: Text('Designation')),
        DataColumn(label: Text('Actions')),
      ],
      rows: staffList
          .asMap()
          .map((index, staff) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(staff['name'] ?? '')),
          DataCell(Text(staff['employee_no'] ?? '')),
          DataCell(Text(staff['mobile_no'] ?? '')),
          DataCell(Text(staff['email'] ?? '')),
          DataCell(Text(staff['address'] ?? '')),
          DataCell(Text(staff['department'] ?? '')),
          DataCell(Text(staff['designation'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(staff: staff);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteStaff(staff['id']);
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
        title: Text('Staff List'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildStaffTable(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showCreateEditDialog();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.deepPurpleAccent,
            heroTag: null,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _bulkUploadStaff,
            child: Icon(Icons.upload_file),
            backgroundColor: Colors.deepPurpleAccent,
            heroTag: null,
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _bulkUploadStaffImages,
            child: Icon(Icons.image),
            backgroundColor: Colors.deepPurpleAccent,
            heroTag: null,
          ),
        ],
      ),
    );
  }
}
