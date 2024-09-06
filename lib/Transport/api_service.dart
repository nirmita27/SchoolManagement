import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

// Fetch petrol pumps from the API
  static Future<List<dynamic>> getPetrolPumps() async {
    final response = await http.get(Uri.parse('$baseUrl/petrol-pumps'));

    if (response.statusCode == 200) {
      return json.decode(response.body);  // Directly return the decoded JSON
    } else {
      throw Exception('Failed to load petrol pumps');
    }
  }
  static Future<void> addPetrolPump(Map<String, dynamic> newPump) async {
    final response = await http.post(
      Uri.parse('$baseUrl/petrol-pumps'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newPump),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add petrol pump');
    }
  }

  static Future<void> deletePetrolPump(int serialNumber) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/petrol-pumps/$serialNumber'),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete petrol pump');
    }
  }

  static Future<List<dynamic>> getBusStops() async {
    final response = await http.get(Uri.parse('$baseUrl/busstops'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load bus stops');
    }
  }

  static Future<void> updateBusStop(int serialNumber, Map<String, dynamic> busStop) async {
    final response = await http.put(
      Uri.parse('$baseUrl/busstops/$serialNumber'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(busStop),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update bus stop');
    }
  }

  static Future<void> addBusStop(Map<String, dynamic> busStop) async {
    final response = await http.post(
      Uri.parse('$baseUrl/busstops'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(busStop),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add bus stop');
    }
  }

  static Future<void> deleteBusStop(int serialNumber) async {
    final response = await http.delete(Uri.parse('$baseUrl/busstops/$serialNumber'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete bus stop');
    }
  }

  static Future<List<dynamic>> getVendors() async {
    final response = await http.get(Uri.parse('$baseUrl/vendors'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load vendors');
    }
  }

  static Future<void> addVendor(Map<String, dynamic> vendor) async {
    final response = await http.post(
      Uri.parse('$baseUrl/vendors'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vendor),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add vendor');
    }
  }

  static Future<void> deleteVendor(int serialNumber) async {
    final response = await http.delete(Uri.parse('$baseUrl/vendors/$serialNumber'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete vendor');
    }
  }

  static Future<void> updateVendor(int serialNumber, Map<String, dynamic> vendor) async {
    final response = await http.put(
      Uri.parse('$baseUrl/vendors/$serialNumber'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(vendor),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update vendor');
    }
  }

  static Future<List<dynamic>> getAssessments() async {
    final response = await http.get(Uri.parse('$baseUrl/assessments'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load assessments');
    }
  }

  static Future<void> addAssessment(Map<String, dynamic> assessment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assessments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(assessment),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add assessment');
    }
  }

  static Future<void> updateAssessment(int serialNo, Map<String, dynamic> assessment) async {
    final response = await http.put(
      Uri.parse('$baseUrl/assessments/$serialNo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(assessment),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update assessment');
    }
  }

  static Future<void> deleteAssessment(int serialNo) async {
    final response = await http.delete(Uri.parse('$baseUrl/assessments/$serialNo'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete assessment');
    }
  }

  static Future<List<dynamic>> getGrades() async {
    final response = await http.get(Uri.parse('$baseUrl/grades'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load grades');
    }
  }

  static Future<void> addGrade(Map<String, dynamic> grade) async {
    final response = await http.post(
      Uri.parse('$baseUrl/grades'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grade),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add grade');
    }
  }

  static Future<void> updateGrade(int serialNo, Map<String, dynamic> grade) async {
    final response = await http.put(
      Uri.parse('$baseUrl/grades/$serialNo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grade),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update grade');
    }
  }

  static Future<void> deleteGrade(int serialNo) async {
    final response = await http.delete(Uri.parse('$baseUrl/grades/$serialNo'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete grade');
    }
  }

  // Fetch terms
  static Future<List<dynamic>> getTerms() async {
    final response = await http.get(Uri.parse('$baseUrl/terms'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load terms');
    }
  }

  // Add term
  static Future<void> addTerm(Map<String, dynamic> termData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/terms'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(termData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add term');
    }
  }

  // Update term
  static Future<void> updateTerm(Map<String, dynamic> termData) async {
    final serialNumber = termData['serial_number'];
    final response = await http.put(
      Uri.parse('$baseUrl/terms/$serialNumber'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(termData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update term');
    }
  }

  // Delete term
  static Future<void> deleteTerm(int serialNumber) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/terms/$serialNumber'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete term');
    }
  }

  static Future<void> addFuelingDetail(Map<String, dynamic> fuelingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/fueling_details'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(fuelingData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add fueling detail');
    }
  }

  static Future<void> addDailyMeterReading(
      Map<String, dynamic> readingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/daily_meter_readings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(readingData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add daily meter reading');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchRoutes() async {
    final response = await http.get(Uri.parse('$baseUrl/routes'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((route) => route as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load routes');
    }
  }

  static Future<void> deleteVehicle(int vehicleId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/vehicles/$vehicleId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete vehicle');
    }
  }

  static Future<void> deleteRoute(int routeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/routes/$routeId'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Method to fetch vehicles from the database
  // static Future<List<Map<String, dynamic>>> getVehicles() async {
  //   final response = await http.get(Uri.parse('$baseUrl/vehicle_master'));
  //
  //   if (response.statusCode == 200) {
  //     List<dynamic> data = json.decode(response.body);
  //     return data.map((vehicle) => vehicle as Map<String, dynamic>).toList();
  //   } else {
  //     throw Exception('Failed to load vehicles');
  //   }
  // }
}