import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../../../core/services/location_service.dart';

class EventController extends ChangeNotifier {
  final EventService _eventService = EventService();
  final LocationService _locationService = LocationService();

  List<EventModel> _regionalEvents = [];
  List<EventModel> _popularEventsGlobal = [];
  bool _isLoadingRegional = true;
  bool _isLoadingPopular = true;
  String _errorMessage = '';
  bool _disposed = false;

  List<EventModel> get regionalEvents => _regionalEvents;
  List<EventModel> get popularEventsGlobal => _popularEventsGlobal;
  bool get isLoadingRegional => _isLoadingRegional;
  bool get isLoadingPopular => _isLoadingPopular;
  String get errorMessage => _errorMessage;

  EventController() {
    loadRegionalEvents();
    loadPopularGlobalEvents();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadRegionalEvents({String? keyword}) async {
    _isLoadingRegional = true;
    if (keyword == null) _errorMessage = '';
    _safeNotifyListeners();

    String? latLong;
    try {
      latLong = await _locationService.getCurrentLocation();
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _isLoadingRegional = false;
      _safeNotifyListeners();
      return;
    }

    try {
      _regionalEvents = await _eventService.fetchEvents(
        latLong: latLong,
        radius: "2500",
        keyword: keyword,
      );
      if (_disposed) return;
      if (_errorMessage.contains('lokasi')) _errorMessage = '';
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _regionalEvents = [];
    }

    _isLoadingRegional = false;
    _safeNotifyListeners();
  }

  Future<void> loadPopularGlobalEvents({String? keyword}) async {
    _isLoadingPopular = true;
    if (keyword == null && !_errorMessage.contains('lokasi')) _errorMessage = '';
    _safeNotifyListeners();

    try {
      _popularEventsGlobal = await _eventService.fetchEvents(
        keyword: keyword,
      );
      if (_disposed) return;
    } catch (e) {
      if (_disposed) return;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _popularEventsGlobal = [];
    }

    _isLoadingPopular = false;
    _safeNotifyListeners();
  }

  Future<void> searchEvents(String keyword) async {
    loadRegionalEvents(keyword: keyword);
    loadPopularGlobalEvents(keyword: keyword);
  }
}