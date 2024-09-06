import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dashboard_screen.dart';

class AdmissionScreen extends StatefulWidget {
  final String schoolRange;

  AdmissionScreen({required this.schoolRange});

  @override
  _AdmissionScreenState createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentDetailsFormKey = GlobalKey<FormState>();
  final _feeDepositFormKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final _aadharNumberController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianAddressController = TextEditingController();
  final _residenceDurationController = TextEditingController();
  final _religionController = TextEditingController();
  final _casteController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _birthCertificateController = TextEditingController();
  final _lastInstitutionController = TextEditingController();
  final _attendanceYearController = TextEditingController();
  final _classController = TextEditingController();
  final _publicExaminationController = TextEditingController();
  final _subjectsController = TextEditingController();

  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _paymentModeController = TextEditingController();

  // New controllers for sibling information
  final _siblingsCurrentlyStudyingController = TextEditingController();
  final _siblingsPreviouslyStudiedController = TextEditingController();

  int _currentStep = 0;
  bool _isDocumentsUploaded = false;
  bool _isVerified = false;
  bool _isFeePaid = false;

  Uint8List? _photo;
  Uint8List? _aadhaar;
  Uint8List? _marksheet;
  Uint8List? _tc;
  Uint8List? _otherDoc;
  Uint8List? _paymentProof;

  String? _photoName;
  String? _aadhaarName;
  String? _marksheetName;
  String? _tcName;
  String? _otherDocName;
  String? _paymentProofName;

  String? _studentId;

  String? _selectedSection;

  Future<void> _pickImage(ImageSource source, Function(Uint8List, String) onPicked) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final fileName = pickedFile.name;
      setState(() {
        onPicked(bytes, fileName);
      });
    }
  }

  Future<void> _submitApplication() async {
    final url = Uri.parse('http://localhost:3000/submitApplication');
    final body = json.encode({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phoneNumber': _phoneNumberController.text,
      'address': _addressController.text,
      'dob': _dobController.text,
      'aadharNumber': _aadharNumberController.text,
      'motherName': _motherNameController.text,
      'fatherName': _fatherNameController.text,
      'fatherOccupation': _fatherOccupationController.text,
      'guardianName': _guardianNameController.text,
      'guardianAddress': _guardianAddressController.text,
      'residenceDuration': _residenceDurationController.text,
      'religion': _religionController.text,
      'caste': _casteController.text,
      'nationality': _nationalityController.text,
      'birthCertificate': _birthCertificateController.text,
      'lastInstitution': _lastInstitutionController.text,
      'attendanceYear': _attendanceYearController.text,
      'class': _classController.text,
      'publicExamination': _publicExaminationController.text,
      'subjects': _subjectsController.text,
      'siblingsCurrentlyStudying': _siblingsCurrentlyStudyingController.text,
      'siblingsPreviouslyStudied': _siblingsPreviouslyStudiedController.text,
      'section': _selectedSection,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        setState(() {
          _studentId = responseData['student_id'].toString();
        });
        // Add student to student_list
        await _addStudentToStudentList();
      } else {
        print('Failed to submit application with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error submitting application: $error');
    }
  }

  Future<void> _addStudentToStudentList() async {
    final url = Uri.parse('http://localhost:3000/addStudent');
    final body = json.encode({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'motherName': _motherNameController.text,
      'fatherName': _fatherNameController.text,
      'address': _addressController.text,
      'phoneNumber': _phoneNumberController.text,
      'classSection': '${_classController.text}-${_selectedSection}',
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        print('Student added to student list successfully');
      } else {
        print('Failed to add student to student list with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error adding student to student list: $error');
    }
  }

  Future<void> _uploadDocument(String documentType, Uint8List bytes) async {
    final url = Uri.parse('http://localhost:3000/uploadDocument');
    final request = http.MultipartRequest('POST', url)
      ..fields['studentId'] = _studentId!
      ..fields['documentType'] = documentType
      ..files.add(http.MultipartFile.fromBytes(
        'document',
        bytes,
        filename: 'document.jpg',
      ));

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        print('Document uploaded successfully');
      } else {
        print('Failed to upload document with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploading document: $error');
    }
  }

  Future<void> _submitFeePayment() async {
    final url = Uri.parse('http://localhost:3000/feePayment');
    final request = http.MultipartRequest('POST', url)
      ..fields['studentId'] = _studentId ?? ''
      ..fields['amount'] = _amountController.text
      ..fields['transactionId'] = _transactionIdController.text
      ..fields['paymentMode'] = _paymentModeController.text
      ..files.add(http.MultipartFile.fromBytes(
        'paymentProof',
        _paymentProof!,
        filename: _paymentProofName!,
      ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        print('Fee payment recorded successfully');
      } else {
        print('Failed to record fee payment with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error recording fee payment: $error');
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_studentDetailsFormKey.currentState!.validate()) {
        _submitApplication().then((_) {
          if (_studentId != null) {
            setState(() {
              _currentStep++;
            });
          } else {
            print('Student ID not set after application submission.');
          }
        });
      }
    } else if (_currentStep == 1) {
      if (_photo != null && _aadhaar != null && _marksheet != null && _tc != null && _otherDoc != null) {
        Future.wait([
          _uploadDocument('Photo', _photo!),
          _uploadDocument('Aadhaar Card', _aadhaar!),
          _uploadDocument('Marksheet', _marksheet!),
          _uploadDocument('Transfer Certificate', _tc!),
          _uploadDocument('Other Documents', _otherDoc!),
        ]).then((_) {
          setState(() {
            _isDocumentsUploaded = true;
            _currentStep++;
          });
        });
      }
    } else if (_currentStep == 2) {
      setState(() {
        _isVerified = true;
        _currentStep++;
      });
    } else if (_currentStep == 3) {
      if (_feeDepositFormKey.currentState!.validate()) {
        _submitFeePayment().then((_) {
          setState(() {
            _isFeePaid = true;
            _currentStep++;
          });
        });
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  List<String> _classOptions() {
    return widget.schoolRange == '6-8'
        ? ['6', '7', '8']
        : ['9', '10', '11', '12'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Admission Process (प्रवेश प्रक्रिया)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen(schoolRange: widget.schoolRange,)),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _onStepContinue,
              onStepCancel: _onStepCancel,
              steps: [
                Step(
                  title: Text('Submit Application (आवेदन जमा करो)'),
                  content: _buildSubmitApplicationForm(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text('Upload Documents (दस्तावेज़ अपलोड करें)'),
                  content: _buildUploadDocumentsForm(),
                  isActive: _currentStep >= 1,
                  state: _isDocumentsUploaded ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text('Document Verification (दस्तावेज़ सत्यापन)'),
                  content: _buildDocumentVerification(),
                  isActive: _currentStep >= 2,
                  state: _isVerified ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text('Fee Deposit (शुल्क जमा)'),
                  content: _buildFeeDepositForm(),
                  isActive: _currentStep >= 3,
                  state: _isFeePaid ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text('Admission Confirmed (प्रवेश की पुष्टि)'),
                  content: _buildAdmissionConfirmed(),
                  isActive: _currentStep >= 4,
                  state: _currentStep == 4 ? StepState.complete : StepState.indexed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _selectedClass;
  final List<String> _sectionOptions = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  Widget _buildClassDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Class for Admission (प्रवेश हेतु कक्षा)',
          border: OutlineInputBorder(),
        ),
        value: _selectedClass,
        items: _classOptions().map((String classOption) {
          return DropdownMenuItem<String>(
            value: classOption,
            child: Text(classOption),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedClass = newValue;
            _classController.text = newValue!;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a class (कृपया एक कक्षा चुनें)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSectionDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Section for Admission (प्रवेश हेतु अनुभाग)',
          border: OutlineInputBorder(),
        ),
        value: _selectedSection,
        items: _sectionOptions.map((String sectionOption) {
          return DropdownMenuItem<String>(
            value: sectionOption,
            child: Text(sectionOption),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedSection = newValue!;
          });
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a section (कृपया एक अनुभाग चुनें)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitApplicationForm() {
    return Form(
      key: _studentDetailsFormKey,
      child: Column(
        children: [
          _buildTextField('First Name (पहला नाम)', _firstNameController),
          _buildTextField('Last Name (उपनाम)', _lastNameController),
          _buildTextField('Email (ईमेल)', _emailController),
          _buildTextField('Phone Number (फ़ोन नंबर)', _phoneNumberController),
          _buildTextField('Address (पता)', _addressController),
          _buildTextField('Date of Birth (जन्म की तारीख)', _dobController),
          _buildTextField('Aadhar Number (आधार नंबर)', _aadharNumberController),
          _buildTextField('Mother\'s Name (मां का नाम)', _motherNameController),
          _buildTextField('Father\'s Name (पिता का नाम)', _fatherNameController),
          _buildTextField('Father\'s Occupation (पिता का व्यवसाय)', _fatherOccupationController),
          _buildTextField('Guardian\'s Name (अभिभावक का नाम)', _guardianNameController),
          _buildTextField('Guardian\'s Address (अभिभावक का पता)', _guardianAddressController),
          _buildTextField('Residence Duration in U.P (यूपी में निवास अवधि)', _residenceDurationController),
          _buildTextField('Religion (धर्म)', _religionController),
          _buildTextField('Caste (जाति)', _casteController),
          _buildTextField('Nationality (राष्ट्रीयता)', _nationalityController),
          _buildTextField('Birth Certificate (जन्म प्रमाणपत्र)', _birthCertificateController),
          _buildTextField('Name of last Last Institution Attended (अंतिम अंतिम संस्थान का नाम जिसमें भाग लिया)', _lastInstitutionController),
          _buildTextField('Weather the Scholar ever attended this institution? If so, mention the year of attendance (क्या विद्वान ने कभी इस संस्था में भाग लिया था? यदि हां, तो उपस्थिति का वर्ष बताएं)', _attendanceYearController),
          _buildClassDropdown(),
          _buildSectionDropdown(),
          _buildTextField('Public Examination Passed with year, division and subjects (सार्वजनिक परीक्षा वर्ष, प्रभाग और विषयों के साथ उत्तीर्ण)', _publicExaminationController),
          _buildTextField('Subjects offered (विषयों की पेशकश की)', _subjectsController),
          // New fields for sibling information
          _buildTextField('Siblings Currently Studying (वर्तमान में अध्ययनरत भाई-बहन)', _siblingsCurrentlyStudyingController),
          _buildTextField('Siblings Previously Studied (पहले अध्ययन किए भाई-बहन)', _siblingsPreviouslyStudiedController),
        ],
      ),
    );
  }

  Widget _buildUploadDocumentsForm() {
    return Column(
      children: [
        _buildUploadButton('Upload Photo (फोटो अपलोड करें)', (bytes, fileName) {
          _photo = bytes;
          _photoName = fileName;
        }),
        _buildUploadedFileName(_photoName),
        _buildUploadButton('Upload Aadhaar Card (आधार कार्ड अपलोड करें)', (bytes, fileName) {
          _aadhaar = bytes;
          _aadhaarName = fileName;
        }),
        _buildUploadedFileName(_aadhaarName),
        _buildUploadButton('Upload Marksheet (मार्कशीट अपलोड करें)', (bytes, fileName) {
          _marksheet = bytes;
          _marksheetName = fileName;
        }),
        _buildUploadedFileName(_marksheetName),
        _buildUploadButton('Upload Transfer Certificate (स्थानांतरण प्रमाणपत्र अपलोड करें)', (bytes, fileName) {
          _tc = bytes;
          _tcName = fileName;
        }),
        _buildUploadedFileName(_tcName),
        _buildUploadButton('Upload Other Documents (अन्य दस्तावेज़ अपलोड करें)', (bytes, fileName) {
          _otherDoc = bytes;
          _otherDocName = fileName;
        }),
        _buildUploadedFileName(_otherDocName),
      ],
    );
  }

  Widget _buildUploadedFileName(String? fileName) {
    return fileName != null
        ? Row(
      children: [
        Text(fileName),
        SizedBox(width: 8),
        Icon(Icons.check_circle, color: Colors.green),
      ],
    )
        : Container();
  }

  Widget _buildDocumentVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Please review the submitted details and documents. Confirm if everything is correct. (कृपया प्रस्तुत विवरण और दस्तावेजों की समीक्षा करें। पुष्टि करें कि क्या सब कुछ सही है)',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        SizedBox(height: 20),
        _buildReviewField('First Name (पहला नाम)', _firstNameController.text),
        _buildReviewField('Last Name (उपनाम)', _lastNameController.text),
        _buildReviewField('Email (ईमेल)', _emailController.text),
        _buildReviewField('Phone Number (फ़ोन नंबर)', _phoneNumberController.text),
        _buildReviewField('Address (पता)', _addressController.text),
        _buildReviewField('Date of Birth (जन्मतिथि)', _dobController.text),
        _buildReviewField('Aadhar Number (आधार नंबर)', _aadharNumberController.text),
        _buildReviewField('Mother\'s Name (मां का नाम)', _motherNameController.text),
        _buildReviewField('Father\'s Name (पिता का नाम)', _fatherNameController.text),
        _buildReviewField('Father\'s Occupation (पिता का व्यवसाय)', _fatherOccupationController.text),
        _buildReviewField('Guardian\'s Name (अभिभावक का नाम)', _guardianNameController.text),
        _buildReviewField('Guardian\'s Address (अभिभावक का पता)', _guardianAddressController.text),
        _buildReviewField('Residence Duration in U.P (यूपी में निवास अवधि)', _residenceDurationController.text),
        _buildReviewField('Religion (धर्म)', _religionController.text),
        _buildReviewField('Caste (जाति)', _casteController.text),
        _buildReviewField('Nationality (राष्ट्रीयता)', _nationalityController.text),
        _buildReviewField('Birth Certificate (जन्म प्रमाणपत्र)', _birthCertificateController.text),
        _buildReviewField('Name of last Last Institution Attended (अंतिम संस्थान का नाम जिसमें भाग लिया)', _lastInstitutionController.text),
        _buildReviewField('Weather the Scholar ever attended this institution? If so, mention the year of attendance', _attendanceYearController.text),
        _buildReviewField('Class to which admission is sought (जिस कक्षा में प्रवेश चाहा गया है)', _classController.text),
        _buildReviewField('Public Examination Passed with year, division and subjects (सार्वजनिक परीक्षा वर्ष, श्रेणी और विषयों के साथ उत्तीर्ण की गई)', _publicExaminationController.text),
        _buildReviewField('Subjects offered (विषयों की पेशकश की)', _subjectsController.text),
        // New review fields for sibling information
        _buildReviewField('Siblings Currently Studying (वर्तमान में अध्ययनरत भाई-बहन)', _siblingsCurrentlyStudyingController.text),
        _buildReviewField('Siblings Previously Studied (पहले अध्ययन किए भाई-बहन)', _siblingsPreviouslyStudiedController.text),
        SizedBox(height: 20),
        _buildDocumentPreview('Uploaded Photo (फोटो अपलोड किया गया)', _photoName),
        _buildDocumentPreview('Uploaded Aadhaar Card (आधार कार्ड अपलोड किया गया)', _aadhaarName),
        _buildDocumentPreview('Uploaded Marksheet (मार्कशीट अपलोड की गई)', _marksheetName),
        _buildDocumentPreview('Uploaded Transfer Certificate (स्थानांतरण प्रमाणपत्र अपलोड किया गया)', _tcName),
        _buildDocumentPreview('Uploaded Other Documents (अन्य दस्तावेज़ अपलोड किए गए)', _otherDocName),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isVerified = true;
                _currentStep++;
              });
            },
            child: Text('Confirm Details (विवरण की पुष्टि करें)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(String label, String? fileName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          fileName != null
              ? Row(
            children: [
              Expanded(
                child: Text(fileName),
              ),
              Icon(Icons.check_circle, color: Colors.green),
            ],
          )
              : Text('No document uploaded'),
        ],
      ),
    );
  }

  Widget _buildFeeDepositForm() {
    return Form(
      key: _feeDepositFormKey,
      child: Column(
        children: [
          _buildTextField('Amount (मात्रा)', _amountController),
          _buildTextField('Transaction ID (लेन-देन आईडी)', _transactionIdController),
          _buildTextField('Payment Mode (भुगतान का प्रकार)', _paymentModeController),
          _buildUploadButton('Upload Payment Proof (भुगतान प्रमाण अपलोड करें)', (bytes, fileName) {
            _paymentProof = bytes;
            _paymentProofName = fileName;
          }),
          _buildUploadedFileName(_paymentProofName),
        ],
      ),
    );
  }

  Widget _buildAdmissionConfirmed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Congratulations! Your admission is confirmed. Welcome to our school. (बधाई हो! आपका प्रवेश पक्का हो गया है. हमारे स्कूल में आपका स्वागत है।)',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen(schoolRange: widget.schoolRange,)),
              );
            },
            child: Text('Proceed to Dashboard (डैशबोर्ड पर आगे बढ़ें)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildUploadButton(String label, Function(Uint8List, String) onPicked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => _pickImage(ImageSource.gallery, onPicked),
        icon: Icon(Icons.upload_file),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent,
        ),
      ),
    );
  }
}
