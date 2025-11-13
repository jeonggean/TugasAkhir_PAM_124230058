import '../../1_event/models/event_model.dart';

class FavoriteModel {
  final String id;
  final String name;
  final String imageUrl;
  final String localDate;
  final String localTime;
  final String timezone;
  final String currency;
  final double minPrice;
  final double maxPrice;
  final String venueName;
  final String venueCity;
  final String venueCountry;

  FavoriteModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.localDate,
    required this.localTime,
    required this.timezone,
    required this.currency,
    required this.minPrice,
    required this.maxPrice,
    required this.venueName,
    required this.venueCity,
    required this.venueCountry,
  });

  factory FavoriteModel.fromEvent(EventModel event) {
    return FavoriteModel(
      id: event.id,
      name: event.name,
      imageUrl: event.imageUrl,
      localDate: event.localDate,
      localTime: event.localTime,
      timezone: event.timezone,
      currency: event.currency,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      venueName: event.venueName,
      venueCity: event.venueCity,
      venueCountry: event.venueCountry,
    );
  }

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://i.imgur.com/gA1q3nJ.png',
      localDate: json['localDate'] ?? '',
      localTime: json['localTime'] ?? '',
      timezone: json['timezone'] ?? '',
      currency: json['currency'] ?? 'USD',
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 0.0,
      venueName: json['venueName'] ?? 'Lokasi tidak tersedia',
      venueCity: json['venueCity'] ?? 'N/A',
      venueCountry: json['venueCountry'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'localDate': localDate,
      'localTime': localTime,
      'timezone': timezone,
      'currency': currency,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'venueName': venueName,
      'venueCity': venueCity,
      'venueCountry': venueCountry,
    };
  }

  EventModel toEventModel() {
    return EventModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      localDate: localDate,
      localTime: localTime,
      timezone: timezone,
      currency: currency,
      minPrice: minPrice,
      maxPrice: maxPrice,
      venueName: venueName,
      venueCity: venueCity,
      venueCountry: venueCountry,
      json: toJson().toString(),
    );
  }
}
