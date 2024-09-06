import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DashboardScreen extends StatefulWidget {
  final String schoolRange;

  DashboardScreen({required this.schoolRange});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedClass;
  String? selectedMonth;
  String? selectedYear;
  int totalCount = 0;
  List<dynamic> applications = [];
  String searchStudentId = '';

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    String url = 'http://localhost:3000/student-applications';
    if (searchStudentId.isNotEmpty) {
      url += '?studentId=$searchStudentId';
    } else {
      List<String> filters = [];
      if (selectedClass != null && selectedClass != 'All') {
        filters.add('classFilter=$selectedClass');
      }
      if (selectedMonth != null) {
        filters.add('month=$selectedMonth');
      }
      if (selectedYear != null) {
        filters.add('year=$selectedYear');
      }
      if (filters.isNotEmpty) {
        url += '?' + filters.join('&');
      }
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          applications = (data['applications'] ?? []).cast<Map<String, dynamic>>();
          totalCount = data['totalCount'] ?? 0;
        });
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      print('Error fetching applications: $e');
      setState(() {
        applications = [];
        totalCount = 0;
      });
    }
  }

  List<String> _classOptions() {
    return widget.schoolRange == '6-8'
        ? ['All', '6', '7', '8']
        : ['All', '9', '10', '11', '12'];
  }

  void _showDocument(BuildContext context, String documentPath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Document (दस्तावेज़)'),
          content: Image.network('http://localhost:3000/$documentPath'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editStudent(Map<String, dynamic> student) {
    TextEditingController firstNameController = TextEditingController(text: student['first_name'] ?? '');
    TextEditingController lastNameController = TextEditingController(text: student['last_name'] ?? '');
    TextEditingController emailController = TextEditingController(text: student['email'] ?? '');
    TextEditingController phoneNumberController = TextEditingController(text: student['phone_number'] ?? '');
    TextEditingController classController = TextEditingController(text: student['class'] ?? '');
    TextEditingController dobController = TextEditingController(text: student['dob'] ?? '');
    TextEditingController aadharController = TextEditingController(text: student['aadhar_number'] ?? '');
    TextEditingController addressController = TextEditingController(text: student['address'] ?? '');
    TextEditingController motherNameController = TextEditingController(text: student['mother_name'] ?? '');
    TextEditingController fatherNameController = TextEditingController(text: student['father_name'] ?? '');
    TextEditingController fatherOccupationController = TextEditingController(text: student['father_occupation'] ?? '');
    TextEditingController guardianNameController = TextEditingController(text: student['guardian_name'] ?? '');
    TextEditingController guardianAddressController = TextEditingController(text: student['guardian_address'] ?? '');
    TextEditingController residenceDurationController = TextEditingController(text: student['residence_duration'] ?? '');
    TextEditingController religionController = TextEditingController(text: student['religion'] ?? '');
    TextEditingController casteController = TextEditingController(text: student['caste'] ?? '');
    TextEditingController nationalityController = TextEditingController(text: student['nationality'] ?? '');
    TextEditingController birthCertificateController = TextEditingController(text: student['birth_certificate'] ?? '');
    TextEditingController lastInstitutionController = TextEditingController(text: student['last_institution'] ?? '');
    TextEditingController attendanceYearController = TextEditingController(text: student['attendance_year'] ?? '');
    TextEditingController publicExaminationController = TextEditingController(text: student['public_examination'] ?? '');
    TextEditingController subjectsController = TextEditingController(text: student['subjects'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Student (छात्र विवरण संपादित करें)'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'First Name (पहला नाम)'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name (उपनाम)'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email (ईमेल)'),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number (फ़ोन नंबर)'),
                ),
                TextField(
                  controller: classController,
                  decoration: InputDecoration(labelText: 'Class (कक्षा)'),
                ),
                TextField(
                  controller: dobController,
                  decoration: InputDecoration(labelText: 'DOB (जन्म तिथि)'),
                ),
                TextField(
                  controller: aadharController,
                  decoration: InputDecoration(labelText: 'Aadhar Number (आधार नंबर)'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address (पता)'),
                ),
                TextField(
                  controller: motherNameController,
                  decoration: InputDecoration(labelText: 'Mother Name (माँ का नाम)'),
                ),
                TextField(
                  controller: fatherNameController,
                  decoration: InputDecoration(labelText: 'Father Name (पिता का नाम)'),
                ),
                TextField(
                  controller: fatherOccupationController,
                  decoration: InputDecoration(labelText: 'Father Occupation (पिता का व्यवसाय)'),
                ),
                TextField(
                  controller: guardianNameController,
                  decoration: InputDecoration(labelText: 'Guardian Name (अभिभावक का नाम)'),
                ),
                TextField(
                  controller: guardianAddressController,
                  decoration: InputDecoration(labelText: 'Guardian Address (अभिभावक का पता)'),
                ),
                TextField(
                  controller: residenceDurationController,
                  decoration: InputDecoration(labelText: 'Residence Duration (निवास अवधि)'),
                ),
                TextField(
                  controller: religionController,
                  decoration: InputDecoration(labelText: 'Religion (धर्म)'),
                ),
                TextField(
                  controller: casteController,
                  decoration: InputDecoration(labelText: 'Caste (जाति)'),
                ),
                TextField(
                  controller: nationalityController,
                  decoration: InputDecoration(labelText: 'Nationality (राष्ट्रीयता)'),
                ),
                TextField(
                  controller: birthCertificateController,
                  decoration: InputDecoration(labelText: 'Birth Certificate (जन्म प्रमाणपत्र)'),
                ),
                TextField(
                  controller: lastInstitutionController,
                  decoration: InputDecoration(labelText: 'Last Institution (अंतिम संस्था)'),
                ),
                TextField(
                  controller: attendanceYearController,
                  decoration: InputDecoration(labelText: 'Attendance Year (उपस्थिति वर्ष)'),
                ),
                TextField(
                  controller: publicExaminationController,
                  decoration: InputDecoration(labelText: 'Public Examination (सार्वजनिक परीक्षा)'),
                ),
                TextField(
                  controller: subjectsController,
                  decoration: InputDecoration(labelText: 'Subjects (विषयों)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> updatedStudent = {
                  'student_id': student['student_id'],
                  'first_name': firstNameController.text,
                  'last_name': lastNameController.text,
                  'email': emailController.text,
                  'phone_number': phoneNumberController.text,
                  'class': classController.text,
                  'dob': dobController.text,
                  'aadhar_number': aadharController.text,
                  'address': addressController.text,
                  'mother_name': motherNameController.text,
                  'father_name': fatherNameController.text,
                  'father_occupation': fatherOccupationController.text,
                  'guardian_name': guardianNameController.text,
                  'guardian_address': guardianAddressController.text,
                  'residence_duration': residenceDurationController.text,
                  'religion': religionController.text,
                  'caste': casteController.text,
                  'nationality': nationalityController.text,
                  'birth_certificate': birthCertificateController.text,
                  'last_institution': lastInstitutionController.text,
                  'attendance_year': attendanceYearController.text,
                  'public_examination': publicExaminationController.text,
                  'subjects': subjectsController.text,
                };

                _updateStudent(updatedStudent);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStudent(Map<String, dynamic> student) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/student-applications/${student['student_id']}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(student),
    );

    if (response.statusCode == 200) {
      _fetchApplications();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student record updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update student record'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteStudent(int studentId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/student-applications/$studentId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      _fetchApplications();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student record deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete student record'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow([
      'Student ID', 'First Name', 'Last Name', 'Email', 'Phone Number', 'Class', 'DOB'
    ]);

    for (var application in applications) {
      sheetObject.appendRow([
        application['student_id']?.toString() ?? 'N/A',
        application['first_name'] ?? 'N/A',
        application['last_name'] ?? 'N/A',
        application['email'] ?? 'N/A',
        application['phone_number'] ?? 'N/A',
        application['class'] ?? 'N/A',
        application['dob'] ?? 'N/A',
      ]);
    }

    final List<int>? bytes = excel.save();
    if (bytes != null) {
      final Uint8List uint8List = Uint8List.fromList(bytes);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => uint8List,
      );
    }
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            headers: [
              'Student ID (छात्र आईडी)', 'First Name (प्रथम नाम)', 'Last Name (अंतिम नाम)', 'Email (ईमेल)', 'Phone Number (फोन नंबर)', 'Class (कक्षा)', 'DOB (जन्मतिथि)'
            ],
            data: applications.map((application) {
              return [
                application['student_id']?.toString() ?? 'N/A',
                application['first_name'] ?? 'N/A',
                application['last_name'] ?? 'N/A',
                application['email'] ?? 'N/A',
                application['phone_number'] ?? 'N/A',
                application['class'] ?? 'N/A',
                application['dob'] ?? 'N/A',
              ];
            }).toList(),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _searchByStudentId() async {
    _fetchApplications();
  }

  DataRow _buildDataRow(BuildContext context, Map<String, dynamic> application) {
    Map<String, String> documents = {
      'Photo': '',
      'Aadhaar Card': '',
      'Marksheet': '',
      'Transfer Certificate': '',
      'Other Documents': '',
      'Payment Proof': '',
    };

    if (application['documents'] != null) {
      for (var doc in application['documents']) {
        documents[doc['document_type']] = doc['document_path'] ?? '';
      }
    }

    if (application['fees'] != null && application['fees'].isNotEmpty) {
      for (var fee in application['fees']) {
        documents['Payment Proof'] = fee['payment_proof_path'] ?? '';
      }
    }

    List<DataCell> cells = [
      DataCell(Text(application['student_id']?.toString() ?? 'N/A')),
      DataCell(Text(application['first_name'] ?? 'N/A')),
      DataCell(Text(application['last_name'] ?? 'N/A')),
      DataCell(Text(application['email'] ?? 'N/A')),
      DataCell(Text(application['phone_number'] ?? 'N/A')),
      DataCell(Text(application['class'] ?? 'N/A')),
      DataCell(Text(application['dob'] ?? 'N/A')),
      DataCell(Text(application['aadhar_number'] ?? 'N/A')),
      DataCell(Text(application['address'] ?? 'N/A')),
      DataCell(Text(application['mother_name'] ?? 'N/A')),
      DataCell(Text(application['father_name'] ?? 'N/A')),
      DataCell(Text(application['father_occupation'] ?? 'N/A')),
      DataCell(Text(application['guardian_name'] ?? 'N/A')),
      DataCell(Text(application['guardian_address'] ?? 'N/A')),
      DataCell(Text(application['residence_duration'] ?? 'N/A')),
      DataCell(Text(application['religion'] ?? 'N/A')),
      DataCell(Text(application['caste'] ?? 'N/A')),
      DataCell(Text(application['nationality'] ?? 'N/A')),
      DataCell(Text(application['birth_certificate'] ?? 'N/A')),
      DataCell(Text(application['last_institution'] ?? 'N/A')),
      DataCell(Text(application['attendance_year'] ?? 'N/A')),
      DataCell(Text(application['public_examination'] ?? 'N/A')),
      DataCell(Text(application['subjects'] ?? 'N/A')),
      DataCell(Text(application['siblings_currently_studying'] ?? 'None')),
      DataCell(Text(application['siblings_previously_studied'] ?? 'None')),
      DataCell(
        documents['Photo']!.isNotEmpty
            ? InkWell(
          onTap: () => _showDocument(context, documents['Photo']!),
          child: Text(
            'View',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        )
            : Text('N/A'),
      ),
      DataCell(
        documents['Aadhaar Card']!.isNotEmpty
            ? InkWell(
          onTap: () => _showDocument(context, documents['Aadhaar Card']!),
          child: Text(
            'View',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        )
            : Text('N/A'),
      ),
      DataCell(
        documents['Marksheet']!.isNotEmpty
            ? InkWell(
          onTap: () => _showDocument(context, documents['Marksheet']!),
          child: Text(
            'View',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        )
            : Text('N/A'),
      ),
      DataCell(
        documents['Transfer Certificate']!.isNotEmpty
            ? InkWell(
          onTap: () => _showDocument(context, documents['Transfer Certificate']!),
          child: Text(
            'View',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        )
            : Text('N/A'),
      ),
      DataCell(
        documents['Other Documents']!.isNotEmpty
            ? InkWell(
          onTap: () => _showDocument(context, documents['Other Documents']!),
          child: Text(
            'View',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        )
            : Text('N/A'),
      ),
      DataCell(
        documents['Payment Proof']!.isNotEmpty
            ? InkWell(
          onTap: () => _showDocument(context, documents['Payment Proof']!),
          child: Text(
            'View',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        )
            : Text('N/A'),
      ),
      DataCell(Text(application['fees'] != null && application['fees'].isNotEmpty ? 'Paid' : 'Not Paid')),
      DataCell(
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _editStudent(application);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _deleteStudent(application['student_id']);
              },
            ),
          ],
        ),
      ),
    ];

    return DataRow(cells: cells);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Dashboard (डैशबोर्ड)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _exportToPDF,
          ),
          IconButton(
            icon: Icon(Icons.table_chart),
            onPressed: _exportToExcel,
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarChartScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedClass,
                      hint: Text("Select Class (कक्षा का चयन करें)", style: TextStyle(color: Colors.black)),
                      onChanged: (value) {
                        setState(() {
                          selectedClass = value;
                          _fetchApplications();
                        });
                      },
                      items: _classOptions()
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.black,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      hint: Text("Select Month (महीना चुनें)", style: TextStyle(color: Colors.black)),
                      onChanged: (value) {
                        setState(() {
                          selectedMonth = value;
                          _fetchApplications();
                        });
                      },
                      items: <String>[
                        'January', 'February', 'March', 'April', 'May', 'June',
                        'July', 'August', 'September', 'October', 'November', 'December'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.black,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedYear,
                      hint: Text("Select Year (वर्ष चुनें)", style: TextStyle(color: Colors.black)),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                          _fetchApplications();
                        });
                      },
                      items: List<String>.generate(10, (int index) {
                        return (DateTime.now().year - index).toString();
                      }).map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.black,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by Student ID (छात्र आईडी द्वारा खोजें)',
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          searchStudentId = value;
                        });
                      },
                      onSubmitted: (value) {
                        _searchByStudentId();
                      },
                    ),
                  ),
                  SizedBox(width: 20),
                  Text('Total Students: $totalCount', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Student ID (स्टूडेंट आईडी)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('First Name (पहला नाम)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Last Name (उपनाम)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Email (ईमेल)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Phone Number (फ़ोन नंबर)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Class (कक्षा)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('DOB (जन्म तिथि)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Aadhar Number (आधार नंबर)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Address (पता)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Mother Name (माँ का नाम)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Father Name (पिता का नाम)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Father Occupation (पिता का व्यवसाय)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Guardian Name (अभिभावक का नाम)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Guardian Address (अभिभावक का पता)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Residence Duration (निवास अवधि)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Religion (धर्म)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Caste (जाति)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Nationality (राष्ट्रीयता)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Birth Certificate (जन्म प्रमाणपत्र)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Last Institution (अंतिम संस्था)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Attendance Year (उपस्थिति वर्ष)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Public Examination (सार्वजनिक परीक्षा)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Subjects (विषयों)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Siblings Currently Studying', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Siblings Previously Studying', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Photo (तस्वीर)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Aadhaar (आधार)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Marksheet (अंक तालिका)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Transfer Certificate (स्थानांतरण प्रमाणपत्र)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Other Documents (अन्य कागजात)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Payment Proof (भुगतान साक्ष्य)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Fee Status (शुल्क स्थिति)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                        DataColumn(label: Text('Actions (कार्रवाई)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                      ],
                      rows: applications
                          .where((application) => widget.schoolRange == '6-8'
                          ? application['class'].startsWith(RegExp(r'^[6-8]'))
                          : application['class'].startsWith(RegExp(r'^[9-12]')))
                          .map<DataRow>((application) => _buildDataRow(context, application)).toList(),
                      dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                        return null;  // Use the default value.
                      }),
                      headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        return Colors.blueGrey.shade800;
                      }),
                      headingTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      dataTextStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      columnSpacing: 12,
                      dividerThickness: 2,
                      showBottomBorder: true,
                      headingRowHeight: 56,
                      dataRowHeight: 56,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChartScreen extends StatefulWidget {
  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  String? selectedFinancialYear;
  Map<String, int> studentCountData = {};

  @override
  void initState() {
    super.initState();
    _fetchStudentCountData();
  }

  Future<void> _fetchStudentCountData() async {
    if (selectedFinancialYear != null) {
      final data = await _fetchStudentCountPerMonth(selectedFinancialYear!);
      setState(() {
        studentCountData = data;
      });
    }
  }

  Future<Map<String, int>> _fetchStudentCountPerMonth(String financialYear) async {
    final url = 'http://localhost:3000/student-count-per-month/$financialYear';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Map<String, int>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch student count');
    }
  }

  Widget _buildStudentCountChart(Map<String, int> data) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.values.reduce((a, b) => a > b ? a : b).toDouble(),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    months[value.toInt()],
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 40,
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 40,
              interval: 10,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: data.entries.map<BarChartGroupData>((entry) {
          final monthIndex = months.indexOf(entry.key);
          return BarChartGroupData(
            x: monthIndex,
            barRods: [
              BarChartRodData(toY: entry.value.toDouble(), color: Colors.teal)
            ],
            showingTooltipIndicators: [0],
          );
        }).toList(),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Count by Month'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedFinancialYear,
            hint: Text("Select Financial Year"),
            onChanged: (value) {
              setState(() {
                selectedFinancialYear = value;
                _fetchStudentCountData();
              });
            },
            items: [
              '2023 - 2024', '2024 - 2025', '2025 - 2026'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          if (studentCountData.isNotEmpty)
            Container(
              height: 400,
              padding: EdgeInsets.all(16.0),
              child: _buildStudentCountChart(studentCountData),
            )
        ],
      ),
    );
  }
}
