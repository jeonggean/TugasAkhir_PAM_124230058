import '../../../core/services/ticketmaster_service.dart';
import '../models/event_model.dart';

class EventService {
  final TicketmasterService _ticketmasterService = TicketmasterService();

  Future<List<EventModel>> fetchEvents({
    String? latLong,
    String? countryCode,
    String? keyword,
    String? radius,
  }) async {
    try {
      final events = await _ticketmasterService.fetchEvents(
        latLong: latLong,
        countryCode: countryCode,
        keyword: keyword,
        radius: radius,
      );

      return events
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Gagal memuat data event. Cek koneksi internet.');
    }
  }
}