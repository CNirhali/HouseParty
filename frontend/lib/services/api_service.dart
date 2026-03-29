import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/party_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to connect to localhost, or localhost for iOS/Web
  static const String baseUrl = 'http://localhost:8000';

  Future<List<Party>> getParties(double lat, double lng, {String? vibe}) async {
    String url = '$baseUrl/parties/?lat=$lat&lng=$lng';
    if (vibe != null && vibe.isNotEmpty) {
      url += '&vibe=$vibe';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Party.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load parties');
    }
  }

  Future<bool> bookParty(int userId, int partyId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'party_id': partyId,
      }),
    );

    return response.statusCode == 200;
  }

  Future<Party> getSecretAddress(int bookingId) async {
    final response = await http.get(Uri.parse('$baseUrl/bookings/$bookingId/secret'));
    
    if (response.statusCode == 200) {
      return Party.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to reveal secret address');
    }
  }
}
