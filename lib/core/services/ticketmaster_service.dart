import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class TicketmasterService {
  final String _apiKey = Constants.ticketMasterApiKey;
  final String _baseUrl = Constants.ticketMasterBaseUrl;

  Future<List<Map<String, dynamic>>> fetchEvents({
    String? latLong,
    String? countryCode,
    String? keyword,
    String? radius,
    int size = 40,
  }) async {
    Map<String, dynamic> params = {
      'apikey': _apiKey,
      'size': '$size',
      'sort': 'date,asc',
      'classificationName': 'Music,Sports,Arts & Theatre',
    };

    if (keyword != null && keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }

    if (latLong != null) {
      params['latlong'] = latLong;
      params['radius'] = radius ?? '100';
      params['unit'] = 'km';
    } else if (countryCode != null && countryCode.isNotEmpty) {
      params['countryCode'] = countryCode;
    }

    try {
      final Uri url = Uri.parse('$_baseUrl/events').replace(queryParameters: params);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> events = data['_embedded']?['events'] ?? [];
        return List<Map<String, dynamic>>.from(events);
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    Map<String, dynamic> params = {
      'apikey': _apiKey,
    };

    try {
      final Uri url = Uri.parse('$_baseUrl/events/$eventId').replace(queryParameters: params);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load event details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching event details: $e');
    }
  }
}
